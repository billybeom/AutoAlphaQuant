// holdings_allocation_fakes.dart — H6-3 widget test and golden shared fakes and helpers.
//
// Rules: extends-only test doubles, all calls recorded,
// new Stream per call, no Korean literals, no if without else, no collection-if.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

class FakeAllocationRepository extends UnimplementedHoldingsRepository {
  FakeAllocationRepository({required this.allocation});

  final Stream<SleeveAllocationVm> Function(int call) allocation;
  int calls = 0;

  @override
  Stream<SleeveAllocationVm> watchAllocation() {
    final int call = calls;
    calls = calls + 1;
    return allocation(call);
  }
}

class FakeNextRebalanceRepository extends UnimplementedRebalanceRepository {
  FakeNextRebalanceRepository({required this.next});

  final Stream<NextRebalanceVm> Function(int call) next;
  int calls = 0;

  @override
  Stream<NextRebalanceVm> watchNext() {
    final int call = calls;
    calls = calls + 1;
    return next(call);
  }
}

List<Override> holdingsAllocationOverrides({
  required FakeAllocationRepository holdings,
  required FakeNextRebalanceRepository rebalance,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalHoldingsRepositoryProvider.overrideWithValue(holdings),
  journalRebalanceRepositoryProvider.overrideWithValue(rebalance),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

Future<void> pumpHoldingsAllocation(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(body: HoldingsAllocation()),
      ),
    ),
  );
  await tester.pump();
}

Future<void> openAllocationNote(WidgetTester tester, int i) async {
  final Finder toggle = find.byKey(ValueKey<String>('h63-note-toggle-$i'));
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pump();
}

List<String> allocationRowTexts(SleeveAllocationRow r) => <String>[
  r.sleeveLabel,
  ?r.sleeveWeight?.label,
  ?r.bandNoteText,
  ?r.bandStateLabel,
  JournalLabels.holdingsDeployed,
  r.deployedText,
  r.deployedPctText,
  JournalLabels.holdingsParking,
  r.parkingText,
  r.parkingPctText,
  r.trancheStateText,
  ?r.parkingNoteText,
  for (final ReasonChip c in r.stateChips) c.label,
];

List<String> nextRebalanceTexts(NextRebalanceVm n) => <String>[
  ?(n.dDayText == null ? null : JournalLabels.holdingsNextRebalance),
  ?n.expectedDateText,
  ?n.dDayText,
  ?n.emptyLabel,
];

Set<String> allocationAllowed(SleeveAllocationVm v, NextRebalanceVm n) => <String>{
  v.asOf.label,
  ?v.noticeText,
  ?v.emptyLabel,
  for (final SleeveAllocationRow r in v.rows) ...<String>[
    ...allocationRowTexts(r),
    ?r.engineColumnNote,
  ],
  ...nextRebalanceTexts(n),
};
