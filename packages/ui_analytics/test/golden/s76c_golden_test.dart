import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../rebalance_preview_fakes.dart';
import 'golden_support.dart';

const Size kS76cGoldenSize = Size(390, 844);

void main() {
  final goldenCases = <({
    String name,
    String countdownPath,
    RebalancePreviewResult? result,
    int safetyRow,
    String bottomKey,
  })>[
    (
      name: 's76c_countdown',
      countdownPath: FixturePaths.m7M7NextRebalanceCountdown,
      result: null,
      safetyRow: 0,
      bottomKey: 's76c-preview-button',
    ),
    (
      name: 's76c_none',
      countdownPath: FixturePaths.m7M7NextRebalanceNone,
      result: null,
      safetyRow: 0,
      bottomKey: 's76c-asof',
    ),
    (
      name: 's76c_preview',
      countdownPath: FixturePaths.m7M7NextRebalanceCountdown,
      result: singleFixture(
        FixturePaths.m7M7RebalancePreviewDefault,
        RebalancePreviewResult.fromJson,
      ),
      safetyRow: 0,
      bottomKey: 's76c-draft-asof',
    ),
    (
      name: 's76c_draft_empty',
      countdownPath: FixturePaths.m7M7NextRebalanceCountdown,
      result: singleFixture(
        FixturePaths.m7M7RebalancePreviewInBand,
        RebalancePreviewResult.fromJson,
      ),
      safetyRow: 0,
      bottomKey: 's76c-draft-asof',
    ),
    (
      name: 's76c_blocked',
      countdownPath: FixturePaths.m7M7NextRebalanceCountdown,
      result: listFixture(
        FixturePaths.m7M7RebalancePreviewBlocked,
        RebalancePreviewResult.fromJson,
      ).rows[0],
      safetyRow: 4,
      bottomKey: 's76c-blocked',
    ),
  ];

  for (final c in goldenCases) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${c.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final NextRebalanceVm vm = singleFixture(
          c.countdownPath,
          NextRebalanceVm.fromJson,
        );
        final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
          vm: vm,
        );
        final FakeRebalancePreviewApi whatIf = c.result != null
            ? FakeRebalancePreviewApi(result: c.result)
            : FakeRebalancePreviewApi();
        final SafetyState safetyState = SafetyState.fromJson(
          fixtureEnvelope(FixturePaths.safetyStates).rows[c.safetyRow],
        );

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: rebalancePreviewOverrides(
              repo: repo,
              whatIf: whatIf,
              safetyState: safetyState,
            ),
            child: const RebalancePreviewScreen(),
          ),
          brightness: b,
          logicalSize: kS76cGoldenSize,
        );
        await tester.pump();

        if (c.result != null) {
          await tester.tap(find.byKey(const Key('s76c-preview-button')));
          await tester.pumpAndSettle();
        }

        expect(
          tester.getBottomLeft(find.byKey(Key(c.bottomKey))).dy,
          lessThan(kS76cGoldenSize.height),
        );

        await expectGolden(c.name, b);
      });
    }
  }
}
