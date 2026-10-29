import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'ledger_fakes.dart';
import 'self_report_fakes.dart';

class _ReceiptCase {
  const _ReceiptCase({
    required this.name,
    required this.watch,
    required this.enabled,
    required this.fieldEnabled,
    required this.declared,
    required this.cleared,
  });

  final String name;
  final CommandReceipt watch;
  final Matcher enabled;
  final Matcher fieldEnabled;
  final Matcher declared;
  final List<DraftKey> cleared;
}

class _ClosedCase {
  const _ClosedCase({
    required this.name,
    required this.session,
    required this.closed,
    required this.form,
  });

  final String name;
  final SelfReportSession session;
  final String? closed;
  final Matcher form;
}

class _BlockedCase {
  const _BlockedCase({
    required this.name,
    required this.session,
    required this.blocked,
    required this.submit,
  });

  final String name;
  final SelfReportSession session;
  final String? blocked;
  final Matcher submit;
}

class _PendingDraftStore extends RecordingDraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) => Completer<DraftRecord?>().future;
}

class _StateCase {
  const _StateCase({
    required this.name,
    required this.session,
    required this.store,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
  });

  final String name;
  final Stream<SelfReportSession> Function(int call) session;
  final DraftStore store;
  final Clock? clock;
  final List<Key> present;
  final List<Key> absent;
  final Matcher stale;
  final Matcher asOfText;
}

class _ResubCase {
  const _ResubCase({
    required this.name,
    required this.first,
    required this.exception,
  });

  final String name;
  final Stream<CommandReceipt> Function() first;
  final Matcher exception;
}

class _RestoredCase {
  const _RestoredCase({
    required this.name,
    required this.watch,
    required this.receipt,
    required this.line0,
    required this.cash,
    required this.cleared,
  });

  final String name;
  final CommandReceipt watch;
  final String? receipt;
  final String line0;
  final String cash;
  final List<DraftKey> cleared;
}

void main() {
  final SelfReportSession session1 = singleFixture(
    FixturePaths.m6SelfReport1,
    SelfReportSession.fromJson,
  );
  final SelfReportSession diffResult = singleFixture(
    FixturePaths.m6SelfReportDiffResult,
    SelfReportSession.fromJson,
  );
  final SelfReportSession closedSession = singleFixture(
    FixturePaths.m6SelfReportSessionClosed,
    SelfReportSession.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture(
    FixturePaths.m6SelfReportReceipts5,
    CommandReceipt.fromJson,
  );
  final ListResult<DraftRecord> drafts = listFixture(
    FixturePaths.m6DraftRecordsX7,
    DraftRecord.fromJson,
  );
  final ManualFillFormSpec blockedSpec = singleFixture(
    FixturePaths.m6FillFormSpecBlocked,
    ManualFillFormSpec.fromJson,
  );

  const String yyyyMm = '2026-08';
  final String alias = drafts.rows[2].selfReport?.accountAlias ?? '';
  final String key2 = '$yyyyMm/$alias';

  testWidgets(
    'L3-01 open session texts, blank inputs, start call, draft load',
    (WidgetTester tester) async {
      expect(drafts.rows[2].key.targetId, key2); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(session1),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('l3-asof')),
          matching: find.text(session1.asOf.label),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-title'))).data,
        session1.titleText,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-notice'))).data,
        session1.noticeText,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-account'))).data,
        session1.accountLabel,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-trade-date'))).data,
        session1.asOfTradeDateText,
      );
      expect(session1.symbols, hasLength(4));
      for (int i = 0; i < session1.symbols.length; i++) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('l3-line-$i')),
            matching: find.text(session1.symbols[i].label),
          ),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(ValueKey<String>('l3-line-$i')))
              .controller
              ?.text,
          '',
        );
      }
      expect(find.byKey(const ValueKey<String>('l3-line-4')), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('l3-cash')))
            .controller
            ?.text,
        '',
      );
      expect(
        tester
            .widget<CheckboxListTile>(find.byKey(const Key('l3-declare')))
            .value,
        isFalse,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('l3-submit')))
            .onPressed,
        isNull,
      );
      expect(actions.ids, <SettingsActionId>[
        SettingsActionId.selfReportSessionStart,
      ]);
      expect(actions.runArgs, <Map<String, String>>[
        <String, String>{'yyyy_mm': yyyyMm, 'account_alias': alias},
      ]);
      expect(repo.args, <(String, String)>[(yyyyMm, alias)]);
      expect(store.loaded, <DraftKey>[drafts.rows[2].key]);
      expect(store.saved, <DraftRecord>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  testWidgets('L3-02 leave stops with same instance and no ref in dispose', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(actions.ids, <SettingsActionId>[
      SettingsActionId.selfReportSessionStart,
      SettingsActionId.selfReportSessionStop,
    ]);
    expect(actions.runArgs, <Map<String, String>>[
      <String, String>{'yyyy_mm': yyyyMm, 'account_alias': alias},
      <String, String>{'yyyy_mm': yyyyMm, 'account_alias': alias},
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('L3-03 blank is not zero and raw submission', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
        opener: opener,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('l3-line-0')),
      ' 3 ',
    );
    await tester.pump();
    expect(store.saved.last.selfReport?.lines.first.quantityText, ' 3 ');
    await tester.enterText(
      find.byKey(const ValueKey<String>('l3-line-1')),
      '0',
    );
    await tester.enterText(find.byKey(const Key('l3-cash')), ' 1000');
    await tester.pump();
    expect(store.saved.last.selfReport?.cashKrwText, ' 1000');
    await tester.ensureVisible(find.byKey(const Key('l3-declare')));
    await tester.tap(find.byKey(const Key('l3-declare')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('l3-submit')));
    await tester.tap(find.byKey(const Key('l3-submit')));
    await tester.pump();
    final SelfReportSubmission s = cmd.submitted.single;
    expect(s.purpose, SelfReportPurpose.periodicAudit);
    expect(s.yyyyMm, yyyyMm);
    expect(s.declaredComplete, isTrue);
    expect(s.input.accountAlias, alias);
    expect(
      <(String, String)>[
        for (final SelfReportLineInput l in s.input.lines)
          (l.symbol, l.quantityText),
      ],
      <(String, String)>[
        (session1.symbols[0].symbol, ' 3 '),
        (session1.symbols[1].symbol, '0'),
        (session1.symbols[2].symbol, ''),
        (session1.symbols[3].symbol, ''),
      ],
    );
    expect(s.input.cashKrwText, ' 1000');
    expect(store.saved.last.selfReport, s.input);
    expect(store.saved.last.lastCommandId, receipts.rows[0].commandId);
    expect(opener.opened, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('L3-04 declaration toggle controls submit button', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('l3-submit'))).onPressed,
      isNull,
    );
    await tester.ensureVisible(find.byKey(const Key('l3-declare')));
    await tester.tap(find.byKey(const Key('l3-declare')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('l3-submit'))).onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('l3-declare')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('l3-submit'))).onPressed,
      isNull,
    );
    expect(cmd.submitted, <SelfReportSubmission>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets(
    'L3-05 draft restore preserves input and declaration is not restored',
    (WidgetTester tester) async {
      expect(
        drafts.rows[2].selfReport?.lines.first.symbol,
        session1.symbols.first.symbol,
      ); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(session1),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[selfReportSeedWithCash(drafts.rows[2], '500')],
      );
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
            .controller
            ?.text,
        drafts.rows[2].selfReport?.lines.first.quantityText,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-1')))
            .controller
            ?.text,
        '',
      );
      expect(session1.symbols, hasLength(4));
      expect(find.byKey(const ValueKey<String>('l3-line-3')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('l3-cash')))
            .controller
            ?.text,
        '500',
      );
      expect(
        tester
            .widget<CheckboxListTile>(find.byKey(const Key('l3-declare')))
            .value,
        isFalse,
      );
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  for (final _ReceiptCase c in <_ReceiptCase>[
    _ReceiptCase(
      name: 'requested',
      watch: receipts.rows[0],
      enabled: isNull,
      fieldEnabled: isFalse,
      declared: isTrue,
      cleared: <DraftKey>[],
    ),
    _ReceiptCase(
      name: 'executed',
      watch: receipts.rows[1],
      enabled: isNull,
      fieldEnabled: isFalse,
      declared: isTrue,
      cleared: <DraftKey>[drafts.rows[2].key],
    ),
    _ReceiptCase(
      name: 'rejected_outside',
      watch: receipts.rows[2],
      enabled: isNotNull,
      fieldEnabled: isTrue,
      declared: isTrue,
      cleared: <DraftKey>[],
    ),
    _ReceiptCase(
      name: 'rejected_invalid',
      watch: receipts.rows[3],
      enabled: isNotNull,
      fieldEnabled: isTrue,
      declared: isTrue,
      cleared: <DraftKey>[],
    ),
    _ReceiptCase(
      name: 'held',
      watch: receipts.rows[4],
      enabled: isNull,
      fieldEnabled: isFalse,
      declared: isTrue,
      cleared: <DraftKey>[],
    ),
  ]) {
    testWidgets('L3-06 receipt branch ${c.name}', (WidgetTester tester) async {
      expect(receipts.rows[1].state, CommandState.executed); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(session1),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(c.watch),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[drafts.rows[2]],
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      await tester.ensureVisible(find.byKey(const Key('l3-declare')));
      await tester.tap(find.byKey(const Key('l3-declare')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('l3-submit')));
      await tester.tap(find.byKey(const Key('l3-submit')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-receipt'))).data,
        c.watch.stateLabel,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('l3-submit')))
            .onPressed,
        c.enabled,
      );
      expect(
        tester.widget<TextField>(find.byKey(const Key('l3-cash'))).enabled,
        c.fieldEnabled,
      );
      expect(
        tester
            .widget<CheckboxListTile>(find.byKey(const Key('l3-declare')))
            .onChanged,
        c.enabled,
      );
      expect(
        tester
            .widget<CheckboxListTile>(find.byKey(const Key('l3-declare')))
            .value,
        c.declared,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
            .controller
            ?.text,
        drafts.rows[2].selfReport?.lines.first.quantityText,
      );
      expect(store.cleared, c.cleared);
      expect(opener.opened, <String>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  for (final _ClosedCase c in <_ClosedCase>[
    _ClosedCase(
      name: 'closed',
      session: closedSession,
      closed: closedSession.sessionClosedText,
      form: findsNothing,
    ),
    _ClosedCase(
      name: 'open',
      session: session1,
      closed: null,
      form: findsOneWidget,
    ),
  ]) {
    testWidgets('L3-07 session closed branch ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(closedSession.sessionClosedText, isNotNull); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(c.session),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      final String? want = c.closed;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('l3-closed'))).data,
          want,
        );
      } else {
        expect(find.byKey(const Key('l3-closed')), findsNothing);
      }
      expect(find.byKey(const ValueKey<String>('l3-line-0')), c.form);
      expect(find.byKey(const Key('l3-submit')), c.form);
      expect(find.byKey(const Key('l3-asof')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('L3-08 result view tiles resolve and next account links', (
    WidgetTester tester,
  ) async {
    final SelfReportResult? res = diffResult.result;
    expect(res, isNotNull); // pre
    expect(res?.diffs.first.actionLink, isNull); // pre
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(diffResult),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
        opener: opener,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    expect(res?.diffs, hasLength(1));
    for (int i = 0; i < (res?.diffs.length ?? 0); i++) {
      expect(
        ledgerShownTexts(tester, find.byKey(ValueKey<String>('l3-diff-$i'))),
        ledgerDiffTexts(res!.diffs[i]),
      );
    }
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('l3-diff-0')),
        matching: find.byType(FilledButton),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('l3-diff-1')), findsNothing);
    expect(find.byKey(const ValueKey<String>('l3-line-0')), findsNothing);
    expect(find.byKey(const Key('l3-submit')), findsNothing);
    expect(find.byKey(const Key('l3-result-empty')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('l3-resolve')));
    await tester.tap(find.byKey(const Key('l3-resolve')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('l3-next-account')));
    await tester.tap(find.byKey(const Key('l3-next-account')));
    await tester.pump();
    expect(opener.opened, <String>[
      res?.resolveLink?.deepLink ?? '',
      res?.nextAccountLink?.deepLink ?? '',
    ]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  for (final _BlockedCase c in <_BlockedCase>[
    _BlockedCase(
      name: 'blocked',
      session: selfReportSessionBlocked(
        session1,
        blockedSpec.blockedText ?? '',
      ),
      blocked: blockedSpec.blockedText,
      submit: findsNothing,
    ),
    _BlockedCase(
      name: 'normal',
      session: session1,
      blocked: null,
      submit: findsOneWidget,
    ),
  ]) {
    testWidgets('L3-09 submit blocked branch ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(blockedSpec.blockedText, isNotNull); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(c.session),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      final String? want = c.blocked;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('l3-blocked'))).data,
          want,
        );
      } else {
        expect(find.byKey(const Key('l3-blocked')), findsNothing);
      }
      expect(find.byKey(const Key('l3-submit')), c.submit);
      expect(find.byKey(const ValueKey<String>('l3-line-0')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  for (final _StateCase c in <_StateCase>[
    _StateCase(
      name: 'draft_pending',
      session: (_) => Stream<SelfReportSession>.value(session1),
      store: _PendingDraftStore(),
      clock: null,
      present: const <Key>[Key('l3-loading')],
      absent: const <Key>[Key('l3-asof'), ValueKey<String>('l3-line-0')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'session_loading',
      session: (_) => Stream<SelfReportSession>.fromFuture(
        Completer<SelfReportSession>().future,
      ),
      store: RecordingDraftStore(),
      clock: null,
      present: const <Key>[Key('l3-loading')],
      absent: const <Key>[Key('l3-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'session_fail',
      session: (_) => Stream<SelfReportSession>.error(StateError('fail')),
      store: RecordingDraftStore(),
      clock: null,
      present: const <Key>[Key('l3-fail')],
      absent: const <Key>[Key('l3-loading'), Key('l3-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'value_then_fail',
      session: (_) => ledgerValueThenFail(session1),
      store: RecordingDraftStore(),
      clock: null,
      present: const <Key>[Key('l3-fail')],
      absent: const <Key>[ValueKey<String>('l3-line-0')],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _StateCase(
      name: 'stale',
      session: (_) => Stream<SelfReportSession>.value(session1),
      store: RecordingDraftStore(),
      clock: ledgerStaleClock(),
      present: const <Key>[Key('l3-asof')],
      absent: const <Key>[
        Key('l3-title'),
        ValueKey<String>('l3-line-0'),
        Key('l3-submit'),
      ],
      stale: findsOneWidget,
      asOfText: findsOneWidget,
    ),
    _StateCase(
      name: 'result_stale',
      session: (_) => Stream<SelfReportSession>.value(diffResult),
      store: RecordingDraftStore(),
      clock: ledgerStaleClock(),
      present: const <Key>[ValueKey<String>('l3-diff-0'), Key('l3-resolve')],
      absent: const <Key>[ValueKey<String>('l3-line-0'), Key('l3-submit')],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
  ]) {
    testWidgets('L3-10 state branches ${c.name}', (WidgetTester tester) async {
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: c.session,
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: c.store,
          clock: c.clock,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(session1.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('L3-11 submit future error shows not accepted banner', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.error(StateError('fail')),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    await tester.ensureVisible(find.byKey(const Key('l3-declare')));
    await tester.tap(find.byKey(const Key('l3-declare')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('l3-submit')));
    await tester.tap(find.byKey(const Key('l3-submit')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('l3-submit-not-accepted'))).data,
      JournalLabels.submitNotAccepted,
    );
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('l3-submit'))).onPressed,
      isNotNull,
    );
    expect(cmd.watched, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
    expect(tester.takeException(), isNotNull);
  });

  for (final _ResubCase c in <_ResubCase>[
    _ResubCase(
      name: 'error_open',
      first: () => Stream<CommandReceipt>.multi(
        (MultiStreamController<CommandReceipt> c) =>
            c.addError(StateError('fail')),
      ),
      exception: isNotNull,
    ),
    _ResubCase(
      name: 'done_empty',
      first: () => const Stream<CommandReceipt>.empty(),
      exception: isNull,
    ),
  ]) {
    testWidgets('L3-12 resubscribe ${c.name}', (WidgetTester tester) async {
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(session1),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (int call) => call == 0
            ? c.first()
            : Stream<CommandReceipt>.value(receipts.rows[0]),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[
          selfReportSeedWithCommand(drafts.rows[2], receipts.rows[0].commandId),
        ],
      );
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      expect(find.byKey(const Key('l3-resubscribe')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
            .enabled,
        isFalse,
      );
      await tester.ensureVisible(find.byKey(const Key('l3-resubscribe')));
      await tester.tap(find.byKey(const Key('l3-resubscribe')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('l3-receipt'))).data,
        receipts.rows[0].stateLabel,
      );
      expect(cmd.watched, <String>[
        receipts.rows[0].commandId,
        receipts.rows[0].commandId,
      ]);
      expect(tester.takeException(), c.exception);
    });
  }

  for (final _RestoredCase c in <_RestoredCase>[
    _RestoredCase(
      name: 'restored_requested',
      watch: receipts.rows[0],
      receipt: receipts.rows[0].stateLabel,
      line0: drafts.rows[2].selfReport?.lines.first.quantityText ?? '',
      cash: '500',
      cleared: <DraftKey>[],
    ),
    _RestoredCase(
      name: 'restored_executed',
      watch: receipts.rows[1],
      receipt: null,
      line0: '',
      cash: '',
      cleared: <DraftKey>[drafts.rows[2].key],
    ),
  ]) {
    testWidgets('L3-13 restored command id ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(drafts.rows[2].lastCommandId, isNull); // pre
      final FakeSelfReportRepository repo = FakeSelfReportRepository(
        session: (_) => Stream<SelfReportSession>.value(session1),
      );
      final FakeSelfReportActions actions = FakeSelfReportActions();
      final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
        submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (_) => Stream<CommandReceipt>.value(c.watch),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[
          selfReportSeedWithCash(
            selfReportSeedWithCommand(
              drafts.rows[2],
              receipts.rows[0].commandId,
            ),
            '500',
          ),
        ],
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSelfReport(
        tester,
        overrides: selfReportOverrides(
          repo: repo,
          actions: actions,
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        yyyyMm: yyyyMm,
        accountAlias: alias,
      );
      expect(cmd.watched, <String>[receipts.rows[0].commandId]);
      final String? wantReceipt = c.receipt;
      if (wantReceipt != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('l3-receipt'))).data,
          wantReceipt,
        );
      } else {
        expect(find.byKey(const Key('l3-receipt')), findsNothing);
      }
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
            .controller
            ?.text,
        c.line0,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('l3-cash')))
            .controller
            ?.text,
        c.cash,
      );
      expect(store.cleared, c.cleared);
      expect(opener.opened, <String>[]);
      expect(cmd.submitted, <SelfReportSubmission>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('L3-14 all text allowed and large text scale factor', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    final Set<String> allowed = selfReportAllowed(session1);
    final List<String?> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data)
        .toList();
    expect(shown, isNotEmpty);
    for (final String? data in shown) {
      expect(data, isIn(allowed));
    }
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('L3-15 retry invalidates session provider', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (int call) => call == 0
          ? Stream<SelfReportSession>.error(StateError('fail'))
          : Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    await tester.ensureVisible(
      find.descendant(
        of: find.byKey(const Key('l3-fail')),
        matching: find.text(JournalLabels.retry),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('l3-fail')),
        matching: find.text(JournalLabels.retry),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('l3-title')), findsOneWidget);
    expect(repo.args, <(String, String)>[(yyyyMm, alias), (yyyyMm, alias)]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('L3-16 submitting disables submit button', (
    WidgetTester tester,
  ) async {
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Completer<CommandReceipt>().future,
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    await tester.ensureVisible(find.byKey(const Key('l3-declare')));
    await tester.tap(find.byKey(const Key('l3-declare')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('l3-submit')));
    await tester.tap(find.byKey(const Key('l3-submit')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('l3-submit'))).onPressed,
      isNull,
    );
    expect(cmd.watched, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('L3-17 restored executed arriving after session clears form', (
    WidgetTester tester,
  ) async {
    final StreamController<CommandReceipt> late =
        StreamController<CommandReceipt>();
    addTearDown(late.close);
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => late.stream,
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[
        selfReportSeedWithCash(
          selfReportSeedWithCommand(drafts.rows[2], receipts.rows[0].commandId),
          '500',
        ),
      ],
    );
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
          .controller
          ?.text,
      drafts.rows[2].selfReport?.lines.first.quantityText,
    );
    late.add(receipts.rows[1]);
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('l3-line-0')))
          .controller
          ?.text,
      '',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('l3-cash')))
          .controller
          ?.text,
      '',
    );
    expect(store.cleared, <DraftKey>[drafts.rows[2].key]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('L3-18 safety banner renders above title and below asof', (
    WidgetTester tester,
  ) async {
    expect(safetyFixtureRow(3).activeFlags, isNotEmpty); // pre
    final FakeSelfReportRepository repo = FakeSelfReportRepository(
      session: (_) => Stream<SelfReportSession>.value(session1),
    );
    final FakeSelfReportActions actions = FakeSelfReportActions();
    final FakeSelfReportCommandApi cmd = FakeSelfReportCommandApi(
      submit: (_) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (_) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpSelfReport(
      tester,
      overrides: selfReportOverrides(
        repo: repo,
        actions: actions,
        cmd: cmd,
        store: store,
        safety: safetyFixtureRow(3),
      ),
      yyyyMm: yyyyMm,
      accountAlias: alias,
    );
    final String flagLabel = safetyFixtureRow(3).activeFlags.first.label;
    expect(find.text(flagLabel), findsOneWidget);
    final double bannerDy = tester.getTopLeft(find.text(flagLabel)).dy;
    final double asofDy = tester
        .getTopLeft(find.byKey(const Key('l3-asof')))
        .dy;
    final double titleDy = tester
        .getTopLeft(find.byKey(const Key('l3-title')))
        .dy;
    expect(bannerDy, greaterThan(asofDy));
    expect(bannerDy, lessThan(titleDy));
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
