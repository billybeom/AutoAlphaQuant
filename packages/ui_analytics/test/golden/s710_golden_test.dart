import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../execution_gap_fakes.dart';
import 'golden_support.dart';

const Size kS710GoldenSize = Size(390, 844);

void main() {
  final List<(String, String, int)> screens = <(String, String, int)>[
    ('s710_cant', FixturePaths.m7ExecutionGapCant, 0),
    ('s710_wont', FixturePaths.m7ExecutionGapWont, 0),
    ('s710_mixed', FixturePaths.m7ExecutionGapMixed, 0),
    ('s710_empty', FixturePaths.m7ExecutionGapEmpty, 0),
    ('s710_not_applicable', FixturePaths.m7ExecutionGapNotApplicable, 0),
    ('s710_masked_recon', FixturePaths.m7ExecutionGapMaskedRecon, 3),
  ];

  for (final (String name, String path, int safetyRow) in screens) {
    for (final Brightness b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        final ExecutionGapResult result = singleFixture(
          path,
          ExecutionGapResult.fromJson,
        );
        final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
          result: result,
        );
        final SafetyState safety = SafetyState.fromJson(
          fixtureEnvelope(FixturePaths.safetyStates).rows[safetyRow],
        );

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: executionGapOverrides(repo: repo, safetyState: safety),
            child: const ExecutionGapScreen(),
          ),
          brightness: b,
          logicalSize: kS710GoldenSize,
        );
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(const Key('s710-asof'))).dy,
          lessThan(kS710GoldenSize.height),
        );

        await expectGolden(name, b);
      });
    }
  }
}
