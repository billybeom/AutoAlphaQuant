// advice_inbox_test.dart — A-1 (AdviceInbox + AdviceCard) widget tests A1-01 ~ A1-16.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_fakes.dart';
import 'golden/golden_support.dart';

FakeAdviceRepository _repo(ListResult<AdviceItem> v, AdviceInboxSummary s) =>
    FakeAdviceRepository(
      inbox: (int call) => Stream<ListResult<AdviceItem>>.value(v),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s),
    );

Finder _row(int i) => find.byKey(ValueKey<String>('a1-row-$i'));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pump();
  await tester.pump();
}

class _DeferCase {
  const _DeferCase({
    required this.name,
    required this.defer,
    required this.steps,
    required this.receipt,
    required this.fail,
    required this.deferred,
  });

  final String name;
  final Future<CommandReceipt> Function(int call) defer;
  final Future<void> Function(WidgetTester tester) steps;
  final String? receipt;
  final String? fail;
  final List<String> deferred;
}

class _EmptyCase {
  const _EmptyCase({
    required this.name,
    required this.inbox,
    required this.summary,
    required this.empty,
  });

  final String name;
  final ListResult<AdviceItem> inbox;
  final AdviceInboxSummary summary;
  final String? empty;
}

class _LinkCase {
  const _LinkCase({
    required this.name,
    required this.inbox,
    required this.summary,
    required this.notice,
    required this.entry,
    required this.steps,
    required this.opened,
  });

  final String name;
  final ListResult<AdviceItem> inbox;
  final AdviceInboxSummary summary;
  final String? notice;
  final Matcher entry;
  final Future<void> Function(WidgetTester tester) steps;
  final List<String> opened;
}

class _StateCase {
  const _StateCase({
    required this.name,
    required this.inbox,
    required this.summary,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
  });

  final String name;
  final Stream<ListResult<AdviceItem>> Function(int call) inbox;
  final Stream<AdviceInboxSummary> Function(int call) summary;
  final Clock? clock;
  final List<String> present;
  final List<String> absent;
  final Matcher stale;
  final Matcher asOfText;
}

void main() {
  final ListResult<AdviceItem> open4 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary s12 = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6Advice12,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> advEmpty = listFixture<AdviceItem>(
    FixturePaths.m6AdviceEmpty,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sEmpty = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceEmpty,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> blocked = listFixture<AdviceItem>(
    FixturePaths.m6AdviceBlocked,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sBlocked = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceBlocked,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final SafetyState safetyBlocked = singleFixture<SafetyState>(
    FixturePaths.m6SafetyAdviceBlocked,
    SafetyState.fromJson,
  );
  final ListResult<AdviceItem> confirm = listFixture<AdviceItem>(
    FixturePaths.m6AdviceExpiredConfirm,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sConfirm = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceExpiredConfirm,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> viewer = listFixture<AdviceItem>(
    FixturePaths.m6AdviceViewer4,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sViewer = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceViewer4,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> noAction = listFixture<AdviceItem>(
    FixturePaths.m6AdviceNoAction,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sNoAction = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceNoAction,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> cooling = listFixture<AdviceItem>(
    FixturePaths.m6AdviceHandoverCooling,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sCooling = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceHandoverCooling,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> stale = listFixture<AdviceItem>(
    FixturePaths.m6AdviceStale,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sStale = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceStale,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture<CommandReceipt>(
    FixturePaths.m6AdviceDeferReceipts3,
    CommandReceipt.fromJson,
  );

  testWidgets('A1-01 full list in received order without args', (
    WidgetTester tester,
  ) async {
    final FakeAdviceRepository repo = _repo(open4, s12);
    await pumpAdviceInbox(tester, overrides: adviceInboxOverrides(repo: repo));

    expect(open4.rows, hasLength(12));
    for (final (int i, AdviceItem r) in open4.rows.indexed) {
      expect(adviceShownTexts(tester, _row(i)), adviceRowTexts(r));
    }
    expect(find.byKey(const ValueKey<String>('a1-row-12')), findsNothing);
    final List<double> ys = <double>[
      for (final Finder f in <Finder>[
        find.byKey(const Key('a1-asof')),
        find.byKey(const Key('a1-summary')),
        for (int i = 0; i < 12; i++) _row(i),
        find.byKey(const Key('a1-history-link')),
      ])
        tester.getTopLeft(f).dy,
    ];
    for (int i = 1; i < ys.length; i++) {
      expect(ys[i], greaterThan(ys[i - 1]));
    }
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a1-summary'))),
      adviceSummaryTexts(s12),
    );
    expect(adviceShownTexts(tester, find.byKey(const Key('a1-asof'))), <String>[
      open4.asOf.label,
    ]);
    expect(repo.inboxArgs, <(AdviceStatus?, int)>[(null, 50)]);
    expect(repo.summaryCalls, 1);
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-02 buttons follow actions and card tap opens detail', (
    WidgetTester tester,
  ) async {
    expect(open4.rows[2].actions.length, 2); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(open4, s12), opener: opener),
    );

    for (final (int i, AdviceItem r) in open4.rows.indexed) {
      expect(
        find.descendant(of: _row(i), matching: find.byType(OutlinedButton)),
        findsNWidgets(r.actions.length),
      );
    }
    final AdviceItem r2 = open4.rows[2];
    final AdviceAction a0 = r2.actions[0];
    final AdviceAction a1 = r2.actions[1];
    await _tap(
      tester,
      find.descendant(of: _row(2), matching: find.text(a0.label)),
    );
    await _tap(
      tester,
      find.descendant(of: _row(2), matching: find.text(a1.label)),
    );
    await _tap(
      tester,
      find.descendant(of: _row(2), matching: find.text(r2.sizingLabel)),
    );
    expect(opener.opened, <String>[
      a0.deepLink,
      a1.deepLink,
      r2.detailDeepLink,
    ]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-03 confirm cards defer button and overdue link', (
    WidgetTester tester,
  ) async {
    expect(confirm.rows[0].deferAvailable, isTrue); // pre
    expect(confirm.rows[1].deferAvailable, isFalse); // pre
    expect(sConfirm.overdueUnrecordedLink, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(
        repo: _repo(confirm, sConfirm),
        opener: opener,
      ),
    );

    expect(confirm.rows, hasLength(3));
    for (final (int i, AdviceItem r) in confirm.rows.indexed) {
      expect(
        find.byKey(ValueKey<String>('a1-defer-$i')),
        r.deferAvailable ? findsOneWidget : findsNothing,
      );
    }
    expect(find.byKey(const ValueKey<String>('a1-row-3')), findsNothing);
    await _tap(tester, find.byKey(const Key('a1-overdue')));
    expect(opener.opened, <String>[sConfirm.overdueUnrecordedLink!.deepLink]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_DeferCase> deferCases = <_DeferCase>[
    _DeferCase(
      name: 'requested',
      defer: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
      steps: (WidgetTester t) async {
        await _tap(t, find.byKey(const ValueKey<String>('a1-defer-0')));
      },
      receipt: receipts.rows[0].stateLabel,
      fail: null,
      deferred: <String>[confirm.rows[0].adviceId],
    ),
    _DeferCase(
      name: 'rejected_second',
      defer: (int call) =>
          Future<CommandReceipt>.value(receipts.rows[call == 0 ? 0 : 2]),
      steps: (WidgetTester t) async {
        await _tap(t, find.byKey(const ValueKey<String>('a1-defer-0')));
        await _tap(t, find.byKey(const ValueKey<String>('a1-defer-0')));
      },
      receipt: receipts.rows[2].stateLabel,
      fail: null,
      deferred: <String>[confirm.rows[0].adviceId, confirm.rows[0].adviceId],
    ),
    _DeferCase(
      name: 'future_error',
      defer: (int call) => Future<CommandReceipt>.error(StateError('fail')),
      steps: (WidgetTester t) async {
        await _tap(t, find.byKey(const ValueKey<String>('a1-defer-0')));
      },
      receipt: null,
      fail: JournalLabels.submitNotAccepted,
      deferred: <String>[confirm.rows[0].adviceId],
    ),
  ];

  for (final _DeferCase c in deferCases) {
    testWidgets('A1-04 defer result branches ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        receipts.rows[2].rejectReasonCode,
        AdviceRejectCodes.deferAlreadyUsed,
      ); // pre
      expect(confirm.rows[0].deferAvailable, isTrue); // pre
      final FakeAdviceCommandApi cmd = FakeAdviceCommandApi(defer: c.defer);
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAdviceInbox(
        tester,
        overrides: adviceInboxOverrides(
          repo: _repo(confirm, sConfirm),
          cmd: cmd,
          opener: opener,
        ),
      );

      final String? want = c.receipt;
      final String? wantFail = c.fail;
      await c.steps(tester);
      if (want != null) {
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey<String>('a1-defer-receipt-0')),
              )
              .data,
          want,
        );
      } else {
        expect(
          find.byKey(const ValueKey<String>('a1-defer-receipt-0')),
          findsNothing,
        );
      }
      if (wantFail != null) {
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey<String>('a1-defer-fail-0')),
              )
              .data,
          wantFail,
        );
      } else {
        expect(
          find.byKey(const ValueKey<String>('a1-defer-fail-0')),
          findsNothing,
        );
      }
      expect(cmd.deferred, c.deferred);
      expect(opener.opened, <String>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A1-16 receipt leaves with its advice after republish', (
    WidgetTester tester,
  ) async {
    expect(confirm.rows[0].deferAvailable, isTrue); // pre
    final StreamController<ListResult<AdviceItem>> inbox =
        StreamController<ListResult<AdviceItem>>();
    addTearDown(() {
      unawaited(inbox.close());
    });
    inbox.add(confirm);
    final FakeAdviceRepository repo = FakeAdviceRepository(
      inbox: (int call) => inbox.stream,
      summary: (int call) => Stream<AdviceInboxSummary>.value(sConfirm),
    );
    final FakeAdviceCommandApi cmd = FakeAdviceCommandApi(
      defer: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
    );
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: repo, cmd: cmd),
    );

    await _tap(tester, find.byKey(const ValueKey<String>('a1-defer-0')));
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('a1-defer-receipt-0')),
          )
          .data,
      receipts.rows[0].stateLabel,
    );
    inbox.add(adviceSlice(confirm, <int>[1, 2]));
    await tester.pump();
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('a1-defer-receipt-0')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('a1-row-0')), findsOneWidget);
    expect(cmd.deferred, <String>[confirm.rows[0].adviceId]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-05 defer in flight disables the button', (
    WidgetTester tester,
  ) async {
    final Completer<CommandReceipt> done = Completer<CommandReceipt>();
    final FakeAdviceCommandApi cmd = FakeAdviceCommandApi(
      defer: (int call) => done.future,
    );
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(confirm, sConfirm), cmd: cmd),
    );

    await _tap(tester, find.byKey(const ValueKey<String>('a1-defer-0')));
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey<String>('a1-defer-0')))
          .onPressed,
      isNull,
    );
    done.complete(receipts.rows[0]);
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey<String>('a1-defer-0')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('a1-defer-receipt-0')),
          )
          .data,
      receipts.rows[0].stateLabel,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-06 viewer shows received text only and no buttons', (
    WidgetTester tester,
  ) async {
    expect(viewer.rows[0].phoneOnlyLabel, isNotNull); // pre
    expect(open4.rows[3].adviceId, viewer.rows[0].adviceId); // pre
    expect(open4.rows[3].symbolLabel, isNotNull); // pre
    expect(open4.rows[3].priceBand, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(
        repo: _repo(viewer, sViewer),
        opener: opener,
      ),
    );

    expect(viewer.rows, hasLength(4));
    for (final (int i, AdviceItem r) in viewer.rows.indexed) {
      expect(
        find.descendant(of: _row(i), matching: find.byType(OutlinedButton)),
        findsNothing,
      );
      expect(
        find.descendant(of: _row(i), matching: find.byType(TextButton)),
        findsNothing,
      );
      expect(adviceShownTexts(tester, _row(i)), adviceRowTexts(r));
    }
    expect(find.text(viewer.rows[0].phoneOnlyLabel!), findsNWidgets(4));
    expect(find.text(open4.rows[3].symbolLabel!), findsNothing);
    expect(find.text(open4.rows[3].priceBand!.label), findsNothing);

    final Set<String> allowed = adviceInboxAllowed(viewer, sViewer);
    final List<String?> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data)
        .toList();
    expect(shown, isNotEmpty);
    for (final String? data in shown) {
      expect(data, isIn(allowed));
    }
    await _tap(
      tester,
      find.descendant(
        of: _row(0),
        matching: find.text(viewer.rows[0].sizingLabel),
      ),
    );
    expect(opener.opened, <String>[viewer.rows[0].detailDeepLink]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-07 suppressed body is not an empty state', (
    WidgetTester tester,
  ) async {
    expect(noAction.rows.single.suppressedLabel, isNotNull); // pre
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(noAction, sNoAction)),
    );

    final AdviceItem r = noAction.rows.single;
    expect(adviceShownTexts(tester, _row(0)), <String?>[
      r.suppressedLabel,
      r.validityLabel,
      for (final ReasonChip c in r.reasons) c.label,
    ]);
    expect(find.text(r.sizingLabel), findsNothing);
    expect(find.text(r.progressLabel), findsNothing);
    expect(find.text(r.statusLabel), findsNothing);
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a1-summary'))),
      adviceSummaryTexts(sNoAction),
    );
    expect(find.byKey(const Key('a1-empty')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_EmptyCase> emptyCases = <_EmptyCase>[
    _EmptyCase(
      name: 'empty',
      inbox: advEmpty,
      summary: sEmpty,
      empty: advEmpty.emptyLabel,
    ),
    _EmptyCase(
      name: 'cooling',
      inbox: cooling,
      summary: sCooling,
      empty: cooling.emptyLabel,
    ),
    _EmptyCase(
      name: 'slice_empty',
      inbox: adviceSlice(open4, <int>[]),
      summary: s12,
      empty: null,
    ),
  ];

  for (final _EmptyCase c in emptyCases) {
    testWidgets('A1-08 empty sentence and cooling ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(advEmpty.rows, isEmpty); // pre
      expect(sCooling.handoverCoolingLabel, isNotNull); // pre
      expect(open4.emptyLabel, isNull); // pre
      await pumpAdviceInbox(
        tester,
        overrides: adviceInboxOverrides(repo: _repo(c.inbox, c.summary)),
      );

      final String? wantEmpty = c.empty;
      if (wantEmpty != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a1-empty'))).data,
          wantEmpty,
        );
      } else {
        expect(find.byKey(const Key('a1-empty')), findsNothing);
      }
      expect(
        adviceShownTexts(tester, find.byKey(const Key('a1-summary'))),
        adviceSummaryTexts(c.summary),
      );
      expect(find.byKey(const Key('a1-history-link')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A1-09 blocking banner is the shared piece', (
    WidgetTester tester,
  ) async {
    expect(safetyBlocked.activeFlags, isNotEmpty); // pre
    expect(sBlocked.trust.upgradeHint, isNotNull); // pre
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(
        repo: _repo(blocked, sBlocked),
        safety: safetyBlocked,
      ),
    );

    final Finder flag = find.text(safetyBlocked.activeFlags.first.label);
    expect(flag, findsOneWidget);
    expect(
      tester.getTopLeft(flag).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('a1-asof'))).dy),
    );
    expect(
      tester.getTopLeft(flag).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('a1-summary'))).dy),
    );
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a1-summary'))),
      adviceSummaryTexts(sBlocked),
    );
    expect(find.text(sBlocked.trust.actionDeepLink!), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-10 missing batch keeps the actions the engine sent', (
    WidgetTester tester,
  ) async {
    expect(sStale.staleLabel, isNotNull); // pre
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(stale, sStale)),
    );

    expect(
      adviceShownTexts(tester, find.byKey(const Key('a1-summary'))),
      adviceSummaryTexts(sStale),
    );
    for (final (int i, AdviceItem r) in stale.rows.indexed) {
      expect(
        find.descendant(of: _row(i), matching: find.byType(OutlinedButton)),
        findsNWidgets(r.actions.length),
      );
    }
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_LinkCase> linkCases = <_LinkCase>[
    _LinkCase(
      name: 'open4',
      inbox: open4,
      summary: s12,
      notice: s12.manualEntryNoticeText,
      entry: findsOneWidget,
      steps: (WidgetTester t) async {
        await _tap(t, find.byKey(const Key('a1-manual-entry')));
        await _tap(t, find.byKey(const Key('a1-history-link')));
      },
      opened: <String>[s12.manualEntryLink!.deepLink, AppRoutes.adviceHistory],
    ),
    _LinkCase(
      name: 'viewer',
      inbox: viewer,
      summary: sViewer,
      notice: null,
      entry: findsNothing,
      steps: (WidgetTester t) async {
        await _tap(t, find.byKey(const Key('a1-history-link')));
      },
      opened: <String>[AppRoutes.adviceHistory],
    ),
  ];

  for (final _LinkCase c in linkCases) {
    testWidgets('A1-11 bottom links ${c.name}', (WidgetTester tester) async {
      expect(s12.manualEntryLink, isNotNull); // pre
      expect(sViewer.manualEntryLink, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAdviceInbox(
        tester,
        overrides: adviceInboxOverrides(
          repo: _repo(c.inbox, c.summary),
          opener: opener,
        ),
      );

      final String? want = c.notice;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a1-manual-notice'))).data,
          want,
        );
      } else {
        expect(find.byKey(const Key('a1-manual-notice')), findsNothing);
      }
      expect(find.byKey(const Key('a1-manual-entry')), c.entry);
      await c.steps(tester);
      expect(opener.opened, c.opened);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A1-12 urgent icon and status chip color', (
    WidgetTester tester,
  ) async {
    expect(open4.rows.where((AdviceItem v) => v.isUrgent), isNotEmpty); // pre
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(open4, s12)),
    );

    for (final (int i, AdviceItem r) in open4.rows.indexed) {
      expect(
        find.descendant(
          of: _row(i),
          matching: find.byIcon(Icons.priority_high),
        ),
        r.isUrgent ? findsOneWidget : findsNothing,
      );
      expect(
        find.descendant(of: _row(i), matching: find.byType(Icon)),
        r.isUrgent ? findsOneWidget : findsNothing,
      );
      final Chip chip = tester.widget<Chip>(
        find.ancestor(
          of: find.descendant(of: _row(i), matching: find.text(r.statusLabel)),
          matching: find.byType(Chip),
        ),
      );
      expect(
        chip.backgroundColor,
        journalToneColor(
          tester.element(find.byType(AdviceInbox)),
          r.statusTone,
        ),
      );
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_StateCase> stateCases = <_StateCase>[
    _StateCase(
      name: 'inbox_loading',
      inbox: (int call) => Stream<ListResult<AdviceItem>>.fromFuture(
        Completer<ListResult<AdviceItem>>().future,
      ),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s12),
      clock: null,
      present: <String>['a1-loading'],
      absent: <String>['a1-asof', 'a1-summary', 'a1-fail', 'a1-history-link'],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'inbox_fail',
      inbox: (int call) =>
          Stream<ListResult<AdviceItem>>.error(StateError('fail')),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s12),
      clock: null,
      present: <String>['a1-fail', 'a1-summary'],
      absent: <String>['a1-loading', 'a1-asof', 'a1-row-0'],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'inbox_value_then_fail',
      inbox: (int call) => adviceValueThenFail<ListResult<AdviceItem>>(open4),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s12),
      clock: null,
      present: <String>['a1-fail', 'a1-summary'],
      absent: <String>['a1-asof', 'a1-row-0'],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _StateCase(
      name: 'summary_loading',
      inbox: (int call) => Stream<ListResult<AdviceItem>>.value(open4),
      summary: (int call) => Stream<AdviceInboxSummary>.fromFuture(
        Completer<AdviceInboxSummary>().future,
      ),
      clock: null,
      present: <String>['a1-asof', 'a1-row-0', 'a1-history-link'],
      absent: <String>['a1-summary', 'a1-manual-entry', 'a1-loading'],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _StateCase(
      name: 'summary_fail',
      inbox: (int call) => Stream<ListResult<AdviceItem>>.value(open4),
      summary: (int call) =>
          Stream<AdviceInboxSummary>.error(StateError('fail')),
      clock: null,
      present: <String>['a1-asof', 'a1-row-0', 'a1-history-link'],
      absent: <String>['a1-summary', 'a1-manual-entry', 'a1-loading'],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _StateCase(
      name: 'stale',
      inbox: (int call) => Stream<ListResult<AdviceItem>>.value(open4),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s12),
      clock: adviceStaleClock(),
      present: <String>['a1-asof', 'a1-summary', 'a1-row-0'],
      absent: <String>['a1-loading', 'a1-fail'],
      stale: findsOneWidget,
      asOfText: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('A1-13 state branches ${c.name}', (WidgetTester tester) async {
      final FakeAdviceRepository repo = FakeAdviceRepository(
        inbox: c.inbox,
        summary: c.summary,
      );
      await pumpAdviceInbox(
        tester,
        overrides: adviceInboxOverrides(repo: repo, clock: c.clock),
      );

      for (final String k in c.present) {
        expect(find.byKey(Key(k)), findsOneWidget);
      }
      for (final String k in c.absent) {
        expect(find.byKey(Key(k)), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(open4.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('A1-14 retry resubscribes the inbox', (
    WidgetTester tester,
  ) async {
    final FakeAdviceRepository repo = FakeAdviceRepository(
      inbox: (int call) => call == 0
          ? Stream<ListResult<AdviceItem>>.error(StateError('fail'))
          : Stream<ListResult<AdviceItem>>.value(open4),
      summary: (int call) => Stream<AdviceInboxSummary>.value(s12),
    );
    await pumpAdviceInbox(tester, overrides: adviceInboxOverrides(repo: repo));

    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('a1-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('a1-row-0')), findsOneWidget);
    expect(repo.inboxArgs, <(AdviceStatus?, int)>[(null, 50), (null, 50)]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A1-15 every Text is allowed and large font has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpAdviceInbox(
      tester,
      overrides: adviceInboxOverrides(repo: _repo(open4, s12)),
    );

    final Set<String> allowed = adviceInboxAllowed(open4, s12);
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
}
