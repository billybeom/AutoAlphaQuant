// test/golden/h63_golden_test.dart — H6-3 HoldingsAllocation golden (4names x light/dark = 8 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/h63_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../holdings_allocation_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1100);

class _Flow {
  const _Flow({
    required this.name,
    required this.allocation,
    required this.safetyRow,
    required this.steps,
  });

  final String name;
  final SleeveAllocationVm allocation;
  final int safetyRow;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final SleeveAllocationVm inBand = singleFixture(
    FixturePaths.m6AllocationInBand,
    SleeveAllocationVm.fromJson,
  );
  final SleeveAllocationVm outOfBand = singleFixture(
    FixturePaths.m6AllocationOutOfBand,
    SleeveAllocationVm.fromJson,
  );
  final SleeveAllocationVm tranche = singleFixture(
    FixturePaths.m6AllocationTrancheProgress,
    SleeveAllocationVm.fromJson,
  );
  final NextRebalanceVm countdown = singleFixture(
    FixturePaths.m7M7NextRebalanceCountdown,
    NextRebalanceVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h63_in_band',
      allocation: inBand,
      safetyRow: 0,
      steps: (_) async {},
    ),
    _Flow(
      name: 'h63_out_of_band',
      allocation: outOfBand,
      safetyRow: 0,
      steps: (_) async {},
    ),
    _Flow(
      name: 'h63_tranche_progress',
      allocation: tranche,
      safetyRow: 0,
      steps: (_) async {},
    ),
    _Flow(
      name: 'h63_pot_under_a',
      allocation: inBand,
      safetyRow: 0,
      steps: (WidgetTester t) async {
        await openAllocationNote(t, 0);
      },
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeAllocationRepository holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(flow.allocation),
        );
        final FakeNextRebalanceRepository rebalance =
            FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
        await pumpForGolden(
          tester,
          const HoldingsAllocation(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: holdingsAllocationOverrides(
              holdings: holdings,
              rebalance: rebalance,
              safety: safetyFixtureRow(flow.safetyRow),
            ),
            child: app,
          ),
        );
        await tester.pump();

        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(const Key('h63-next'))).dy,
          lessThan(_kTallPhone.height),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('h63-asof'))).dy,
          0.0,
        );
        await expectGolden(flow.name, b);
      });
    }
  }
}
