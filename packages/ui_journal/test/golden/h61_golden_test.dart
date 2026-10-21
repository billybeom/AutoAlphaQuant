// test/golden/h61_golden_test.dart — H6-1 보유현황 골든 (5이름 × light/dark = 10장)
//
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/h61_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../holdings_overview_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 2480);

/// 골든 한 장의 흐름 — 이름마다 입력 두 값 · 안전 행 · 흐름 클로저.
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
  final HoldingsOverviewVm closed; // includePnl false 의 값
  final HoldingsOverviewVm open; // includePnl true 의 값
  final int safetyRow;
  final Future<void> Function(WidgetTester tester) steps;
  final String bottomKey;
}

void main() {
  final HoldingsOverviewVm normal = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewNormal,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm recon = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewRecon,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm integrity = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewIntegrity,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm empty = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewEmpty,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm pnl = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewPnl,
    HoldingsOverviewVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h61_normal',
      closed: normal,
      open: pnl,
      safetyRow: 0,
      steps: (WidgetTester t) => openHoldingsCard(t, 1),
      bottomKey: 'h61-ext',
    ),
    _Flow(
      name: 'h61_recon_mismatch',
      closed: recon,
      open: pnl,
      safetyRow: 3,
      steps: (WidgetTester t) => openHoldingsCard(t, 1),
      bottomKey: 'h61-ext',
    ),
    _Flow(
      name: 'h61_integrity',
      closed: integrity,
      open: pnl,
      safetyRow: 4,
      steps: (WidgetTester t) async {},
      bottomKey: 'h61-ext',
    ),
    _Flow(
      name: 'h61_empty',
      closed: empty,
      open: empty,
      safetyRow: 0,
      steps: (WidgetTester t) async {},
      bottomKey: 'h61-empty',
    ),
    _Flow(
      name: 'h61_pnl_expanded',
      closed: normal,
      open: pnl,
      safetyRow: 0,
      steps: (WidgetTester t) async {
        await tapHoldingsPnlToggle(t);
        await openHoldingsCard(t, 0);
        await openHoldingsCard(t, 1);
        await openHoldingsCard(t, 2);
      },
      bottomKey: 'h61-ext',
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeHoldingsRepository repo = fakeHoldingsOverview(
          flow.closed,
          flow.open,
        );
        await pumpForGolden(
          tester,
          const HoldingsOverview(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: holdingsOverviewOverrides(
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
          tester.getBottomLeft(find.byKey(Key(flow.bottomKey))).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('h61-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
