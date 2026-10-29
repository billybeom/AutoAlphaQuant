// self_report_fakes.dart - L-3 self report widget test and golden helpers.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

class FakeSelfReportRepository extends UnimplementedLedgerTrustRepository {
  FakeSelfReportRepository({required this.session});

  final Stream<SelfReportSession> Function(int call) session;
  final List<(String, String)> args = <(String, String)>[];

  @override
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  ) {
    final int call = args.length;
    args.add((yyyyMm, accountAlias));
    return session(call);
  }
}

class FakeSelfReportActions extends UnimplementedSettingsActions {
  final List<SettingsActionId> ids = <SettingsActionId>[];
  final List<Map<String, String>> runArgs = <Map<String, String>>[];

  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) {
    ids.add(id);
    runArgs.add(args);
    return super.run(id, args: args);
  }
}

class FakeSelfReportCommandApi extends UnimplementedCommandApi {
  FakeSelfReportCommandApi({required this.submit, required this.watch});

  final Future<CommandReceipt> Function(int call) submit;
  final Stream<CommandReceipt> Function(int call) watch;

  final List<SelfReportSubmission> submitted = <SelfReportSubmission>[];
  final List<String> watched = <String>[];

  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) {
    final int call = submitted.length;
    submitted.add(submission);
    return submit(call);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    final int call = watched.length;
    watched.add(commandId);
    return watch(call);
  }
}

List<Override> selfReportOverrides({
  required FakeSelfReportRepository repo,
  required SettingsActions actions,
  required CommandApi cmd,
  required DraftStore store,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalLedgerTrustRepositoryProvider.overrideWithValue(repo),
  journalSettingsActionsProvider.overrideWithValue(actions),
  journalCommandApiProvider.overrideWithValue(cmd),
  journalDraftStoreProvider.overrideWithValue(store),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

Future<void> pumpSelfReport(
  WidgetTester tester, {
  required List<Override> overrides,
  required String yyyyMm,
  required String accountAlias,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: SelfReportForm(
            yyyyMm: yyyyMm,
            accountAlias: accountAlias,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

DraftRecord selfReportSeedWithCommand(DraftRecord r, String commandId) =>
    r.copyWith(lastCommandId: commandId);

DraftRecord selfReportSeedWithCash(DraftRecord r, String cash) =>
    r.copyWith(selfReport: r.selfReport?.copyWith(cashKrwText: cash));

SelfReportSession selfReportSessionBlocked(
  SelfReportSession s,
  String text,
) => s.copyWith(blockedText: text);

Set<String> selfReportAllowed(SelfReportSession s) => <String>{
  s.asOf.label,
  s.titleText,
  s.noticeText,
  s.accountLabel,
  s.asOfTradeDateText,
  for (final SymbolOption x in s.symbols) x.label,
  s.cashHintLabel,
  s.declareCompleteLabel,
  JournalLabels.draftSubmit,
  ?s.blockedText,
};
