// ledger_fakes.dart — L-1 · L-2 widget test and golden shared fakes and helpers.
//
// Rules: extends-only test doubles, all calls recorded,
// new Stream per call, no Korean literals, no if without else, no collection-if.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class FakeLedgerDiffsRepository extends UnimplementedLedgerRepository {
  FakeLedgerDiffsRepository({required this.diffs});

  final Stream<ListResult<LedgerDiffRow>> Function(int call) diffs;
  int calls = 0;

  @override
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs() {
    final int call = calls;
    calls = calls + 1;
    return diffs(call);
  }
}

class FakeLedgerRepairsRepository extends UnimplementedLedgerRepository {
  FakeLedgerRepairsRepository({required this.repairs});

  final Stream<ListResult<LedgerRepairRow>> Function(int call) repairs;
  final List<int> limits = <int>[];

  @override
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50}) {
    final int call = limits.length;
    limits.add(limit);
    return repairs(call);
  }
}

// ── Overrides ─────────────────────────────────────────────────────────────────

List<Override> ledgerOverrides({
  required LedgerRepository repo,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalLedgerRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

// ── Pump helpers ──────────────────────────────────────────────────────────────

Future<void> pumpLedgerDiffs(
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
      child: const MaterialApp(home: Scaffold(body: LedgerDiffs())),
    ),
  );
  await tester.pump();
}

Future<void> pumpLedgerRepairs(
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
      child: const MaterialApp(home: Scaffold(body: LedgerRepairs())),
    ),
  );
  await tester.pump();
}

// ── Slice helpers ─────────────────────────────────────────────────────────────

ListResult<LedgerDiffRow> ledgerDiffSlice(
  ListResult<LedgerDiffRow> source,
  List<int> pick,
) => source.copyWith(
  rows: <LedgerDiffRow>[for (final int i in pick) source.rows[i]],
  hasMore: false,
);

ListResult<LedgerRepairRow> ledgerRepairSlice(
  ListResult<LedgerRepairRow> source,
  List<int> pick,
) => source.copyWith(
  rows: <LedgerRepairRow>[for (final int i in pick) source.rows[i]],
  hasMore: false,
);

// ── Clock helpers ─────────────────────────────────────────────────────────────

Stream<T> ledgerValueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

Clock ledgerStaleClock() =>
    FixedClock(kGoldenNowUtc.add(const Duration(days: 2)));

// ── Text helpers ──────────────────────────────────────────────────────────────

List<String?> ledgerShownTexts(WidgetTester tester, Finder scope) => tester
    .widgetList<Text>(
      find.descendant(of: scope, matching: find.byType(Text)),
    )
    .map((Text t) => t.data)
    .toList();

List<String> ledgerDiffTexts(LedgerDiffRow r) => <String>[
  r.pairLabel,
  r.axisLabel,
  r.severityLabel,
  r.deltaLabel,
  r.statusLabel,
  r.routeLabel,
  JournalLabels.ledgerCandidateOrigins,
  for (final ReasonChip c in r.candidateOrigins) c.label,
  r.detectedAtText,
  JournalLabels.ledgerEvidence,
  r.evidenceHash,
  ?r.actionLink?.label,
];

List<String> ledgerRepairTexts(LedgerRepairRow r) => <String>[
  r.directionLabel,
  r.label,
  r.originLabel,
  r.targetText,
  r.appliedAtText,
  ?r.supersededLabel,
  r.chainStampText,
  ?r.decisionLink?.label,
];

Set<String> ledgerDiffsAllowed(ListResult<LedgerDiffRow> v) => <String>{
  v.asOf.label,
  ?v.emptyLabel,
  for (final LedgerDiffRow r in v.rows) ...ledgerDiffTexts(r),
  JournalLabels.ledgerRepairsLink,
};

Set<String> ledgerRepairsAllowed(ListResult<LedgerRepairRow> v) => <String>{
  v.asOf.label,
  ?v.emptyLabel,
  for (final LedgerRepairRow r in v.rows) ...ledgerRepairTexts(r),
};
