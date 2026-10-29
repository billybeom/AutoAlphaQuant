// manual_fill_fakes.dart - A-3 manual fill widget test and golden helpers.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_skip_fakes.dart';
import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

class FakeManualFillCommandApi extends UnimplementedCommandApi {
  FakeManualFillCommandApi({required this.record, required this.watch});

  final Future<CommandReceipt> Function(int call) record;
  final Stream<CommandReceipt> Function(int call) watch;

  final List<ManualFillSubmission> recorded = <ManualFillSubmission>[];
  final List<String> watched = <String>[];

  @override
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission) {
    final int call = recorded.length;
    recorded.add(submission);
    return record(call);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    final int call = watched.length;
    watched.add(commandId);
    return watch(call);
  }
}

List<Override> manualFillOverrides({
  required FakeAdviceFormRepository repo,
  required CommandApi cmd,
  required DraftStore store,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalAdviceRepositoryProvider.overrideWithValue(repo),
  journalCommandApiProvider.overrideWithValue(cmd),
  journalDraftStoreProvider.overrideWithValue(store),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

Future<void> pumpManualFill(
  WidgetTester tester, {
  required List<Override> overrides,
  required String adviceId,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: ManualFillForm(adviceId: adviceId)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

DraftRecord manualFillSeedWithCommand(DraftRecord r, String commandId) =>
    r.copyWith(lastCommandId: commandId);

Future<void> manualFillPick(
  WidgetTester tester,
  Key dropdown,
  String label,
) async {
  await tester.ensureVisible(find.byKey(dropdown));
  await tester.tap(find.byKey(dropdown));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Set<String> manualFillAllowed(ManualFillFormSpec s, AdviceItem v) => <String>{
  s.asOf.label,
  ?s.bannerText,
  ...adviceFormRefTexts(v),
  ?v.prefillQuantityLabel,
  JournalLabels.manualFillTradeDate,
  for (final TradeDateOption o in s.tradeDateOptions) o.label,
  JournalLabels.manualFillSymbol,
  for (final SymbolOption x in s.symbols) x.label,
  JournalLabels.manualFillSide,
  for (final SideOption o in s.sides) o.label,
  JournalLabels.manualFillQuantity,
  JournalLabels.manualFillPrice,
  s.priceHintLabel,
  JournalLabels.commission,
  JournalLabels.tax,
  JournalLabels.manualFillAccount,
  for (final AccountOption a in s.accounts) a.label,
  s.appendOnlyNotice,
  JournalLabels.draftSubmit,
  ?s.blockedText,
};
