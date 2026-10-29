// advice_skip_form_test.dart — AdviceSkipForm widget tests A4-01 ~ A4-12.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_fakes.dart';
import 'advice_skip_fakes.dart';
import 'golden/golden_support.dart';

class _PendingLoadStore extends RecordingDraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) => Completer<DraftRecord?>().future;
}

class _BudgetCase {
  const _BudgetCase({
    required this.name,
    required this.steps,
    required this.opened,
  });

  final String name;
  final Future<void> Function(WidgetTester tester) steps;
  final List<String> opened;
}

class _ReceiptCase {
  const _ReceiptCase({
    required this.name,
    required this.watch,
    required this.enabled,
    required this.cleared,
    required this.opened,
  });

  final String name;
  final CommandReceipt watch;
  final Matcher enabled;
  final List<DraftKey> cleared;
  final List<String> opened;
}

class _RestoreCase {
  const _RestoreCase({
    required this.name,
    required this.watch,
    required this.receipt,
    required this.enabled,
    required this.cleared,
  });

  final String name;
  final CommandReceipt watch;
  final String? receipt;
  final Matcher enabled;
  final List<DraftKey> cleared;
}

class _BlockCase {
  const _BlockCase({
    required this.name,
    required this.spec,
    required this.blocked,
    required this.banner,
    required this.reasons,
  });

  final String name;
  final ManualFillFormSpec spec;
  final String? blocked;
  final String? banner;
  final Matcher reasons;
}

class _StateCase {
  const _StateCase({
    required this.name,
    required this.item,
    required this.spec,
    required this.store,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
  });

  final String name;
  final Future<AdviceItem?> Function(int call) item;
  final Stream<ManualFillFormSpec> Function(int call) spec;
  final DraftStore store;
  final List<Key> present;
  final List<Key> absent;
  final Matcher stale;
  final Matcher asOfText;
}

class _RetryCase {
  const _RetryCase({
    required this.name,
    required this.item,
    required this.spec,
    required this.findArgs,
    required this.specCalls,
  });

  final String name;
  final Future<AdviceItem?> Function(int call) item;
  final Stream<ManualFillFormSpec> Function(int call) spec;
  final List<String> findArgs;
  final int specCalls;
}

void main() {
  final AdviceItem ad0001 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  ).rows[3];
  final ManualFillFormSpec spec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpec,
    ManualFillFormSpec.fromJson,
  );
  final ManualFillFormSpec blockedSpec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpecBlocked,
    ManualFillFormSpec.fromJson,
  );
  final ManualFillFormSpec staleSpec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpecStale,
    ManualFillFormSpec.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture<CommandReceipt>(
    FixturePaths.m6AdviceSkipReceipts5,
    CommandReceipt.fromJson,
  );
  final ListResult<DraftRecord> drafts = listFixture<DraftRecord>(
    FixturePaths.m6DraftRecordsX7,
    DraftRecord.fromJson,
  );

  Future<AdviceItem?> Function(int call) itemOf(AdviceItem? v) =>
      (int call) => Future<AdviceItem?>.value(v);
  Stream<ManualFillFormSpec> Function(int call) specOf(ManualFillFormSpec v) =>
      (int call) => Stream<ManualFillFormSpec>.value(v);
  Future<CommandReceipt> Function(int call) skipOf(CommandReceipt r) =>
      (int call) => Future<CommandReceipt>.value(r);
  Stream<CommandReceipt> Function(int call) watchOf(CommandReceipt r) =>
      (int call) => Stream<CommandReceipt>.value(r);

  FakeAdviceFormRepository repoOf({
    Future<AdviceItem?> Function(int call)? item,
    Stream<ManualFillFormSpec> Function(int call)? spec0,
  }) => FakeAdviceFormRepository(
    item: item ?? itemOf(ad0001),
    spec: spec0 ?? specOf(spec),
  );

  Future<void> tapKey(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pump();
    await tester.pump();
  }

  Finder reason(int i) => find.byKey(ValueKey<String>('a4-reason-$i'));
  Future<void> tapReason(WidgetTester tester, int i) =>
      tapKey(tester, reason(i));
  VoidCallback? pressedOf(WidgetTester tester, int i) =>
      tester.widget<OutlinedButton>(reason(i)).onPressed;
  double dyOf(WidgetTester tester, Key k) =>
      tester.getTopLeft(find.byKey(k)).dy;

  testWidgets('A4-01 all texts in received order and no save before a tap', (
    WidgetTester tester,
  ) async {
    expect(drafts.rows[1].key.targetId, ad0001.adviceId); // pre
    final RecordingDraftStore store = RecordingDraftStore();
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(
        repo: repoOf(),
        cmd: UnimplementedCommandApi(),
        store: store,
      ),
      adviceId: ad0001.adviceId,
    );

    expect(
      adviceShownTexts(tester, find.byKey(const Key('a4-asof'))),
      <String?>[spec.asOf.label],
    );
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a4-ref'))),
      adviceFormRefTexts(ad0001),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('a4-notice'))).data,
      spec.skipNoticeText,
    );
    expect(spec.skipReasons, hasLength(6));
    for (final (int i, ReasonOption o) in spec.skipReasons.indexed) {
      expect(adviceShownTexts(tester, reason(i)), <String?>[o.label]);
    }
    expect(reason(6), findsNothing);
    expect(find.byType(OutlinedButton), findsNWidgets(6));
    expect(find.byType(TextField), findsNothing);
    final List<double> dys = <double>[
      dyOf(tester, const Key('a4-asof')),
      dyOf(tester, const Key('a4-ref')),
      dyOf(tester, const Key('a4-notice')),
      dyOf(tester, const ValueKey<String>('a4-reason-0')),
      dyOf(tester, const ValueKey<String>('a4-reason-1')),
      dyOf(tester, const ValueKey<String>('a4-reason-2')),
      dyOf(tester, const ValueKey<String>('a4-reason-3')),
      dyOf(tester, const ValueKey<String>('a4-reason-4')),
      dyOf(tester, const ValueKey<String>('a4-reason-5')),
    ];
    for (int i = 1; i < dys.length; i = i + 1) {
      expect(dys[i], greaterThan(dys[i - 1]));
    }
    expect(store.loaded, <DraftKey>[drafts.rows[1].key]);
    expect(store.saved, <DraftRecord>[]);
    expect(find.byKey(const Key('a4-receipt')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A4-02 one tap submits and saves once afterwards', (
    WidgetTester tester,
  ) async {
    expect(spec.skipReasons[1].deepLink, isNull); // pre
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
      skip: skipOf(receipts.rows[0]),
      watch: watchOf(receipts.rows[0]),
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(
        repo: repoOf(),
        cmd: cmd,
        store: store,
        opener: opener,
      ),
      adviceId: ad0001.adviceId,
    );

    await tapReason(tester, 1);

    expect(cmd.skipped.single.adviceId, ad0001.adviceId);
    expect(cmd.skipped.single.input.toJson(), <String, dynamic>{
      'reason': spec.skipReasons[1].code,
      'note': '',
    });
    expect(store.saved.single.lastCommandId, receipts.rows[0].commandId);
    expect(store.saved.single.adviceSkip?.toJson(), <String, dynamic>{
      'reason': spec.skipReasons[1].code,
      'note': '',
    });
    expect(store.saved.single.key, drafts.rows[1].key);
    expect(cmd.watched, <String>[receipts.rows[0].commandId]);
    expect(opener.opened, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_BudgetCase> budgetCases = <_BudgetCase>[
    _BudgetCase(
      name: 'budget_price',
      steps: (WidgetTester t) => tapReason(t, 0),
      opened: <String>[spec.skipReasons[0].deepLink!],
    ),
    _BudgetCase(
      name: 'budget_pause',
      steps: (WidgetTester t) => tapReason(t, 2),
      opened: <String>[spec.skipReasons[2].deepLink!],
    ),
  ];
  for (final _BudgetCase c in budgetCases) {
    testWidgets('A4-03 budget code only pushes ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(spec.skipReasons[0].deepLink, isNotNull); // pre
      expect(spec.skipReasons[2].deepLink, isNotNull); // pre
      final RecordingDraftStore store = RecordingDraftStore();
      final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
        skip: skipOf(receipts.rows[0]),
        watch: watchOf(receipts.rows[0]),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: repoOf(),
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        adviceId: ad0001.adviceId,
      );

      await c.steps(tester);

      expect(opener.opened, c.opened);
      expect(cmd.skipped, <AdviceSkipSubmission>[]);
      expect(store.saved, <DraftRecord>[]);
      expect(store.cleared, <DraftKey>[]);
      expect(find.byKey(const Key('a4-receipt')), findsNothing);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  final List<_ReceiptCase> receiptCases = <_ReceiptCase>[
    _ReceiptCase(
      name: 'requested',
      watch: receipts.rows[0],
      enabled: isNull,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _ReceiptCase(
      name: 'executed',
      watch: receipts.rows[1],
      enabled: isNull,
      cleared: <DraftKey>[drafts.rows[1].key],
      opened: <String>[AppNavActions.back],
    ),
    _ReceiptCase(
      name: 'rejected_lease',
      watch: receipts.rows[2],
      enabled: isNotNull,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _ReceiptCase(
      name: 'rejected_not_open',
      watch: receipts.rows[3],
      enabled: isNotNull,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _ReceiptCase(
      name: 'held',
      watch: receipts.rows[4],
      enabled: isNull,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
  ];
  for (final _ReceiptCase c in receiptCases) {
    testWidgets('A4-04 receipt branch ${c.name}', (WidgetTester tester) async {
      expect(receipts.rows[1].state, CommandState.executed); // pre
      final RecordingDraftStore store = RecordingDraftStore();
      final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
        skip: skipOf(receipts.rows[0]),
        watch: watchOf(c.watch),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: repoOf(),
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        adviceId: ad0001.adviceId,
      );

      await tapReason(tester, 1);

      expect(
        tester.widget<Text>(find.byKey(const Key('a4-receipt'))).data,
        c.watch.stateLabel,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey<String>('a4-reason-1')),
            )
            .onPressed,
        c.enabled,
      );
      expect(store.cleared, c.cleared);
      expect(opener.opened, c.opened);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A4-05 submit future error shows one not accepted line', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
      skip: (int call) => Future<CommandReceipt>.error(StateError('fail')),
      watch: watchOf(receipts.rows[0]),
    );
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(repo: repoOf(), cmd: cmd, store: store),
      adviceId: ad0001.adviceId,
    );

    await tapReason(tester, 1);

    expect(
      tester.widget<Text>(find.byKey(const Key('a4-submit-not-accepted'))).data,
      JournalLabels.submitNotAccepted,
    );
    expect(store.saved, <DraftRecord>[]);
    expect(cmd.watched, <String>[]);
    expect(pressedOf(tester, 1), isNotNull);
    expect(find.byKey(const Key('a4-receipt')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
    expect(tester.takeException(), isNotNull);
  });

  final List<_RestoreCase> restoreCases = <_RestoreCase>[
    _RestoreCase(
      name: 'restored_requested',
      watch: receipts.rows[0],
      receipt: receipts.rows[0].stateLabel,
      enabled: isNull,
      cleared: <DraftKey>[],
    ),
    _RestoreCase(
      name: 'restored_executed',
      watch: receipts.rows[1],
      receipt: null,
      enabled: isNotNull,
      cleared: <DraftKey>[drafts.rows[1].key],
    ),
  ];
  for (final _RestoreCase c in restoreCases) {
    testWidgets('A4-06 restored command id ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(drafts.rows[1].lastCommandId, isNull); // pre
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[
          adviceSkipSeedWithCommand(drafts.rows[1], receipts.rows[0].commandId),
        ],
      );
      final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
        skip: skipOf(receipts.rows[0]),
        watch: watchOf(c.watch),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: repoOf(),
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        adviceId: ad0001.adviceId,
      );
      await tester.pump();

      expect(cmd.watched, <String>[receipts.rows[0].commandId]);
      final String? want = c.receipt;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a4-receipt'))).data,
          want,
        );
      } else {
        expect(find.byKey(const Key('a4-receipt')), findsNothing);
      }
      expect(pressedOf(tester, 1), c.enabled);
      expect(store.cleared, c.cleared);
      expect(opener.opened, <String>[]);
      expect(cmd.skipped, <AdviceSkipSubmission>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A4-07 resubscribe after a stream error', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[
        adviceSkipSeedWithCommand(drafts.rows[1], receipts.rows[0].commandId),
      ],
    );
    final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
      skip: skipOf(receipts.rows[0]),
      watch: (int call) => call == 0
          ? Stream<CommandReceipt>.error(StateError('fail'))
          : Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(repo: repoOf(), cmd: cmd, store: store),
      adviceId: ad0001.adviceId,
    );
    await tester.pump();

    expect(find.byKey(const Key('a4-resubscribe')), findsOneWidget);
    expect(pressedOf(tester, 1), isNull);
    await tapKey(tester, find.byKey(const Key('a4-resubscribe')));

    expect(find.byKey(const Key('a4-resubscribe')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('a4-receipt'))).data,
      receipts.rows[0].stateLabel,
    );
    expect(cmd.watched, <String>[
      receipts.rows[0].commandId,
      receipts.rows[0].commandId,
    ]);
    expect(tester.takeException(), isNotNull);
  });

  final List<_BlockCase> blockCases = <_BlockCase>[
    _BlockCase(
      name: 'blocked',
      spec: blockedSpec,
      blocked: blockedSpec.blockedText,
      banner: blockedSpec.bannerText,
      reasons: findsNothing,
    ),
    _BlockCase(
      name: 'normal',
      spec: spec,
      blocked: null,
      banner: null,
      reasons: findsOneWidget,
    ),
  ];
  for (final _BlockCase c in blockCases) {
    testWidgets('A4-08 blocked text and form banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(blockedSpec.blockedText, isNotNull); // pre
      expect(blockedSpec.bannerText, isNotNull); // pre
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: repoOf(spec0: specOf(c.spec)),
          cmd: UnimplementedCommandApi(),
          store: RecordingDraftStore(),
        ),
        adviceId: ad0001.adviceId,
      );

      final String? wantBlocked = c.blocked;
      if (wantBlocked != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a4-blocked'))).data,
          wantBlocked,
        );
      } else {
        expect(find.byKey(const Key('a4-blocked')), findsNothing);
      }
      final String? wantBanner = c.banner;
      if (wantBanner != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a4-banner'))).data,
          wantBanner,
        );
      } else {
        expect(find.byKey(const Key('a4-banner')), findsNothing);
      }
      expect(reason(0), c.reasons);
      expect(find.byKey(const Key('a4-notice')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  final List<_StateCase> stateCases = <_StateCase>[
    _StateCase(
      name: 'draft_pending',
      item: itemOf(ad0001),
      spec: specOf(spec),
      store: _PendingLoadStore(),
      present: const <Key>[Key('a4-loading')],
      absent: const <Key>[Key('a4-asof'), Key('a4-ref')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'item_loading',
      item: (int call) => Completer<AdviceItem?>().future,
      spec: specOf(spec),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-loading')],
      absent: const <Key>[Key('a4-asof'), Key('a4-absent')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'item_fail',
      item: (int call) => Future<AdviceItem?>.error(StateError('fail')),
      spec: specOf(spec),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-fail')],
      absent: const <Key>[Key('a4-loading'), Key('a4-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'item_null',
      item: itemOf(null),
      spec: specOf(spec),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-absent')],
      absent: const <Key>[
        Key('a4-asof'),
        Key('a4-ref'),
        ValueKey<String>('a4-reason-0'),
      ],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'spec_loading',
      item: itemOf(ad0001),
      spec: (int call) => Stream<ManualFillFormSpec>.fromFuture(
        Completer<ManualFillFormSpec>().future,
      ),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-loading')],
      absent: const <Key>[Key('a4-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'spec_fail',
      item: itemOf(ad0001),
      spec: (int call) => Stream<ManualFillFormSpec>.error(StateError('fail')),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-fail')],
      absent: const <Key>[Key('a4-loading'), Key('a4-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'spec_stale',
      item: itemOf(ad0001),
      spec: specOf(staleSpec),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-asof')],
      absent: const <Key>[
        Key('a4-ref'),
        Key('a4-notice'),
        ValueKey<String>('a4-reason-0'),
        Key('a4-blocked'),
      ],
      stale: findsOneWidget,
      asOfText: findsNothing,
    ),
    _StateCase(
      name: 'spec_value_then_fail',
      item: itemOf(ad0001),
      spec: (int call) => adviceValueThenFail<ManualFillFormSpec>(spec),
      store: RecordingDraftStore(),
      present: const <Key>[Key('a4-fail')],
      absent: const <Key>[Key('a4-asof'), Key('a4-ref')],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
  ];
  for (final _StateCase c in stateCases) {
    testWidgets('A4-09 state branches ${c.name}', (WidgetTester tester) async {
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: FakeAdviceFormRepository(item: c.item, spec: c.spec),
          cmd: UnimplementedCommandApi(),
          store: c.store,
        ),
        adviceId: ad0001.adviceId,
      );

      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(spec.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('A4-10 every Text is allowed and large font has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(
        repo: repoOf(),
        cmd: UnimplementedCommandApi(),
        store: RecordingDraftStore(),
      ),
      adviceId: ad0001.adviceId,
    );

    final Set<String> allowed = adviceSkipAllowed(spec, ad0001);
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

  final List<_RetryCase> retryCases = <_RetryCase>[
    _RetryCase(
      name: 'item',
      item: (int call) => call == 0
          ? Future<AdviceItem?>.error(StateError('fail'))
          : Future<AdviceItem?>.value(ad0001),
      spec: specOf(spec),
      findArgs: <String>[ad0001.adviceId, ad0001.adviceId],
      specCalls: 1,
    ),
    _RetryCase(
      name: 'spec',
      item: itemOf(ad0001),
      spec: (int call) => call == 0
          ? Stream<ManualFillFormSpec>.error(StateError('fail'))
          : Stream<ManualFillFormSpec>.value(spec),
      findArgs: <String>[ad0001.adviceId],
      specCalls: 2,
    ),
  ];
  for (final _RetryCase c in retryCases) {
    testWidgets('A4-11 retry ${c.name}', (WidgetTester tester) async {
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: c.item,
        spec: c.spec,
      );
      await pumpAdviceSkip(
        tester,
        overrides: adviceSkipOverrides(
          repo: repo,
          cmd: UnimplementedCommandApi(),
          store: RecordingDraftStore(),
        ),
        adviceId: ad0001.adviceId,
      );

      await tapKey(
        tester,
        find.descendant(
          of: find.byKey(const Key('a4-fail')),
          matching: find.text(JournalLabels.retry),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('a4-ref')), findsOneWidget);
      expect(repo.findArgs, c.findArgs);
      expect(repo.specCalls, c.specCalls);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A4-12 buttons are locked while submitting', (
    WidgetTester tester,
  ) async {
    final FakeAdviceSkipCommandApi cmd = FakeAdviceSkipCommandApi(
      skip: (int call) => Completer<CommandReceipt>().future,
      watch: watchOf(receipts.rows[0]),
    );
    await pumpAdviceSkip(
      tester,
      overrides: adviceSkipOverrides(
        repo: repoOf(),
        cmd: cmd,
        store: RecordingDraftStore(),
      ),
      adviceId: ad0001.adviceId,
    );

    await tapReason(tester, 1);

    expect(pressedOf(tester, 1), isNull);
    expect(pressedOf(tester, 2), isNull);
    expect(cmd.watched, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
