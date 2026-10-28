// test/golden/l1_golden_test.dart — L-1 LedgerDiffs golden (4 names x light/dark = 8 PNG).
//
// Rules: --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/l1_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../ledger_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 844);

class _Flow {
  const _Flow({
    required this.name,
    required this.input,
    required this.steps,
  });
  final String name;
  final ListResult<LedgerDiffRow> input;
  final Future<void> Function(WidgetTester) steps;
}

void main() {
  final ListResult<LedgerDiffRow> full = listFixture(
    FixturePaths.ledgerDiffs4,
    LedgerDiffRow.fromJson,
  );
  final ListResult<LedgerDiffRow> cash = listFixture(
    FixturePaths.m6LedgerDiffsCashObserve,
    LedgerDiffRow.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'l1_broker_qty',
      input: ledgerDiffSlice(full, <int>[0]),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'l1_cash_observe',
      input: cash,
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'l1_accepted',
      input: ledgerDiffSlice(full, <int>[2]),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'l1_push_lag',
      input: ledgerDiffSlice(full, <int>[1]),
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
          const LedgerDiffs(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: ledgerOverrides(
              repo: FakeLedgerDiffsRepository(
                diffs: (int call) =>
                    Stream<ListResult<LedgerDiffRow>>.value(flow.input),
              ),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byKey(const Key('l1-repairs-link'))).dy,
          lessThan(_kTallPhone.height),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('l1-asof'))).dy,
          0.0,
        );
        await expectGolden(flow.name, b);
      });
    }
  }
}
