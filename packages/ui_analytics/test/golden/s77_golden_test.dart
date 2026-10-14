// packages/ui_analytics/test/golden/s77_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../annual_review_fakes.dart';
import 'golden_support.dart';

const Size kS77GoldenSize = Size(390, 1440);

void main() {
  final List<(String, String)> screens = <(String, String)>[
    ('s77_december', FixturePaths.m7M7Annual2026),
    ('s77_first_year', FixturePaths.m7M7AnnualFirstYear),
    ('s77_offwindow', FixturePaths.m7M7AnnualOffwindow),
  ];

  for (final (String name, String path) in screens) {
    for (final Brightness b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        final AnnualReviewVm vm = singleFixture(path, AnnualReviewVm.fromJson);
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: annualReviewOverrides(repo: repo),
            child: const AnnualReviewScreen(),
          ),
          brightness: b,
          logicalSize: kS77GoldenSize,
        );
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(const Key('s77-asof'))).dy,
          lessThan(kS77GoldenSize.height),
        );

        await expectGolden(name, b);
      });
    }
  }

  for (final Brightness b in Brightness.values) {
    testWidgets('s77_aftertax_ladder_spec ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final AnnualReviewVm vm = singleFixture(
        FixturePaths.m7M7Annual2026,
        AnnualReviewVm.fromJson,
      );
      final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
        vm: vm,
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: annualReviewOverrides(repo: repo),
          child: const AnnualReviewScreen(),
        ),
        brightness: b,
        logicalSize: kS77GoldenSize,
      );
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s77-aftertax'))).dy,
        lessThan(kS77GoldenSize.height),
      );

      await expectLater(
        find.byKey(const Key('s77-aftertax')),
        matchesGoldenFile(
          'goldens/s77_aftertax_ladder_spec_${brightnessSuffix(b)}.png',
        ),
      );
    });

    testWidgets('s77_aftertax_ladder_cf ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final AnnualReviewVm vm = singleFixture(
        FixturePaths.m7M7Annual2026,
        AnnualReviewVm.fromJson,
      );
      final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
        vm: vm,
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: annualReviewOverrides(repo: repo),
          child: const AnnualReviewScreen(),
        ),
        brightness: b,
        logicalSize: kS77GoldenSize,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('s77-cf-toggle')));
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s77-aftertax'))).dy,
        lessThan(kS77GoldenSize.height),
      );

      await expectLater(
        find.byKey(const Key('s77-aftertax')),
        matchesGoldenFile(
          'goldens/s77_aftertax_ladder_cf_${brightnessSuffix(b)}.png',
        ),
      );
    });
  }
}
