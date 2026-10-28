// test/golden/l2_golden_test.dart — L-2 LedgerRepairs golden (2 names x light/dark = 4 PNG).
//
// Rules: --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/l2_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../ledger_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1200);

class _Flow {
  const _Flow({
    required this.name,
    required this.input,
    required this.steps,
    required this.bottomKey,
  });
  final String name;
  final ListResult<LedgerRepairRow> input;
  final Future<void> Function(WidgetTester) steps;
  final Key bottomKey;
}

void main() {
  final ListResult<LedgerRepairRow> four = listFixture(
    FixturePaths.m6LedgerRepairs4,
    LedgerRepairRow.fromJson,
  );
  final ListResult<LedgerRepairRow> empty = listFixture(
    FixturePaths.m6LedgerRepairsEmpty,
    LedgerRepairRow.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'l2_chain_two_repairs',
      input: four,
      steps: (WidgetTester t) async {},
      bottomKey: const ValueKey<String>('l2-row-3'),
    ),
    _Flow(
      name: 'l2_empty',
      input: empty,
      steps: (WidgetTester t) async {},
      bottomKey: const Key('l2-empty'),
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const LedgerRepairs(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: ledgerOverrides(
              repo: FakeLedgerRepairsRepository(
                repairs: (int call) =>
                    Stream<ListResult<LedgerRepairRow>>.value(flow.input),
              ),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byKey(flow.bottomKey)).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('l2-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
