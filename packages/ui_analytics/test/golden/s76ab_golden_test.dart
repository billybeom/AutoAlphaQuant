// packages/ui_analytics/test/golden/s76ab_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../rebalance_fakes.dart';
import 'golden_support.dart';

const Size kS76abGoldenSize = Size(390, 960);

void main() {
  final listCases = <(String, String)>[
    ('s76a_list', FixturePaths.rebalance6),
    ('s76a_empty', FixturePaths.m7M7RebalanceEmpty),
    ('s76a_sim', FixturePaths.m7M7RebalanceSim),
  ];

  for (final (String name, String fixturePath) in listCases) {
    for (final Brightness b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        final ListResult<RebalanceEvent> page = listFixture(
          fixturePath,
          RebalanceEvent.fromJson,
        );
        final repo = FakeRebalanceRepository(events: page);

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: rebalanceOverrides(repo: repo),
            child: const RebalanceTimelineScreen(),
          ),
          brightness: b,
          logicalSize: kS76abGoldenSize,
        );
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.text(page.asOf.label)).dy,
          lessThan(kS76abGoldenSize.height),
        );

        await expectGolden(name, b);
      });
    }
  }

  final eventCases = <(String, RebalanceEvent)>[
    (
      's76b_band',
      singleFixture(
        FixturePaths.m7M7RebalanceDetailBand,
        RebalanceEvent.fromJson,
      ),
    ),
    ('s76b_seasonal', rebalance6Event(kSeasonalEventId)),
    (
      's76b_advisory',
      singleFixture(
        FixturePaths.m7M7RebalanceDetailAdvisory,
        RebalanceEvent.fromJson,
      ),
    ),
  ];

  for (final (String name, RebalanceEvent event) in eventCases) {
    for (final Brightness b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        final repo = FakeRebalanceRepository(event: event);

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: rebalanceOverrides(repo: repo),
            child: RebalanceEventScreen(rebalanceEventId: event.eventId),
          ),
          brightness: b,
          logicalSize: kS76abGoldenSize,
        );
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(const Key('s76b-asof'))).dy,
          lessThan(kS76abGoldenSize.height),
        );

        await expectGolden(name, b);
      });
    }
  }
}
