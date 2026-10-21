// test/golden/h62_golden_test.dart — H6-2 HoldingDetail golden (4names x light/dark = 8 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/h62_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../holding_detail_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1400);

class _Flow {
  const _Flow({
    required this.name,
    required this.closed,
    required this.open,
    required this.safetyRow,
    required this.steps,
    required this.bottomKey,
  });

  final String name;
  final HoldingDetailVm closed;
  final HoldingDetailVm open;
  final int safetyRow;
  final Future<void> Function(WidgetTester tester) steps;
  final Key bottomKey;
}

void main() {
  final HoldingDetailVm noStop = singleFixture(
    FixturePaths.m6HoldingDetailNoStop,
    HoldingDetailVm.fromJson,
  );
  final HoldingDetailVm pnl = singleFixture(
    FixturePaths.m6HoldingDetailPnl,
    HoldingDetailVm.fromJson,
  );
  final HoldingDetailVm recon = singleFixture(
    FixturePaths.m6HoldingDetailRecon,
    HoldingDetailVm.fromJson,
  );
  final HoldingDetailVm integrity = singleFixture(
    FixturePaths.m6HoldingDetailIntegrity,
    HoldingDetailVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h62_etf_no_stop',
      closed: noStop,
      open: pnl,
      safetyRow: 0,
      steps: (_) async {},
      bottomKey: const Key('h62-recent-empty'),
    ),
    _Flow(
      name: 'h62_pnl_expanded',
      closed: noStop,
      open: pnl,
      safetyRow: 0,
      steps: (WidgetTester t) async {
        await tapHoldingDetailPnlToggle(t);
      },
      bottomKey: const Key('h62-recent-empty'),
    ),
    _Flow(
      name: 'h62_recon_mismatch',
      closed: recon,
      open: pnl,
      safetyRow: 3,
      steps: (_) async {},
      bottomKey: const Key('h62-recent-empty'),
    ),
    _Flow(
      name: 'h62_integrity',
      closed: integrity,
      open: pnl,
      safetyRow: 4,
      steps: (_) async {},
      bottomKey: const ValueKey<String>('h62-entry-1'),
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeHoldingDetailRepository repo = fakeHoldingDetail(
          flow.closed,
          flow.open,
        );
        await pumpForGolden(
          tester,
          HoldingDetail(holdingId: flow.closed.holding.holdingId),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: holdingDetailOverrides(
              repo: repo,
              safety: safetyFixtureRow(flow.safetyRow),
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
        expect(
          tester.getTopLeft(find.byKey(const Key('h62-asof'))).dy,
          0.0,
        );
        await expectGolden(flow.name, b);
      });
    }
  }
}
