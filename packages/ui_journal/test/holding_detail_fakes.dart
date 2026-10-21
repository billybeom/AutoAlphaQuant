// holding_detail_fakes.dart — H6-2 widget test and golden shared fakes and helpers.
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

class FakeHoldingDetailRepository extends UnimplementedHoldingsRepository {
  FakeHoldingDetailRepository({required this.detail});

  final Stream<HoldingDetailVm> Function(
    String holdingId,
    bool includePnl,
    int call,
  )
  detail;

  final List<(String, bool)> calls = <(String, bool)>[];

  @override
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  }) {
    final int call = calls.length;
    calls.add((holdingId, includePnl));
    return detail(holdingId, includePnl, call);
  }
}

FakeHoldingDetailRepository fakeHoldingDetail(
  HoldingDetailVm closed,
  HoldingDetailVm open,
) => FakeHoldingDetailRepository(
  detail: (String id, bool includePnl, int call) =>
      Stream<HoldingDetailVm>.value(includePnl ? open : closed),
);

List<Override> holdingDetailOverrides({
  required FakeHoldingDetailRepository repo,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalHoldingsRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

Future<void> pumpHoldingDetail(
  WidgetTester tester, {
  required List<Override> overrides,
  required String holdingId,
  Key? screenKey,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: HoldingDetail(key: screenKey, holdingId: holdingId),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> tapHoldingDetailPnlToggle(WidgetTester tester) async {
  final Finder toggle = find.byKey(const Key('h62-pnl-toggle'));
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pump();
  await tester.pump();
}

List<String> holdingDetailSummaryTexts(HoldingRow h) => <String>[
  h.symbolLabel,
  h.quantityText,
  ?h.pendingText,
  ?h.subBookLabel,
  JournalLabels.holdingsAvgPrice,
  h.avgPriceText,
  JournalLabels.holdingsEntryDate,
  h.entryDate.yyyyMmDd,
  h.weightText,
  for (final ReasonChip c in h.entryReasons) c.label,
  for (final TrancheStep s in h.smaTranches) s.label,
  for (final GateBadge g in h.gates) g.label,
];

List<String> holdingDetailStopTexts(StopLineNormalized s) => <String>[
  s.tierLabel,
  s.levelText,
  s.basisLabel,
];

Set<String> holdingDetailAllowed(HoldingDetailVm v) => <String>{
  v.asOf.label,
  v.sleeveLabel,
  ...holdingDetailSummaryTexts(v.holding),
  ?v.pnlToggleLabel,
  ?v.holding.pnl?.pnlText,
  ?v.holding.pnl?.pnlPctText,
  ?v.holding.pnl?.disclosureNote,
  v.entryDecisionLink.label,
  JournalLabels.holdingsStopLines,
  for (final StopLineNormalized s in v.stopLines) ...holdingDetailStopTexts(s),
  ?v.noStopLineText,
  JournalLabels.holdingsRecentEntries,
  ?v.recentEmptyLabel,
};
