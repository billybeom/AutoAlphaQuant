import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_fakes.dart';
import 'advice_skip_fakes.dart';
import 'golden/golden_support.dart';
import 'manual_fill_fakes.dart';

class _NeverDraftStore extends RecordingDraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) => Completer<DraftRecord?>().future;
}

class _A303Case {
  const _A303Case({
    required this.name,
    required this.item,
    required this.prefill,
  });

  final String name;
  final AdviceItem item;
  final String? prefill;
}

class _A305Case {
  const _A305Case({
    required this.name,
    required this.watch,
    required this.enabled,
    required this.fieldEnabled,
    required this.retry,
    required this.cleared,
    required this.opened,
  });

  final String name;
  final CommandReceipt watch;
  final Matcher enabled;
  final Matcher fieldEnabled;
  final String? retry;
  final List<DraftKey> cleared;
  final List<String> opened;
}

class _A308Case {
  const _A308Case({
    required this.name,
    required this.watch,
    required this.receipt,
    required this.enabled,
    required this.quantity,
    required this.cleared,
  });

  final String name;
  final CommandReceipt watch;
  final String? receipt;
  final Matcher enabled;
  final String quantity;
  final List<DraftKey> cleared;
}

class _A309Case {
  const _A309Case({
    required this.name,
    required this.spec,
    required this.blocked,
    required this.banner,
    required this.submit,
  });

  final String name;
  final ManualFillFormSpec spec;
  final String? blocked;
  final String? banner;
  final Matcher submit;
}

class _A313Case {
  const _A313Case({
    required this.name,
    required this.item,
    required this.spec,
    required this.store,
    required this.present,
    required this.absent,
    required this.asOfText,
  });

  final String name;
  final Future<AdviceItem?> Function(int call) item;
  final Stream<ManualFillFormSpec> Function(int call) spec;
  final RecordingDraftStore store;
  final List<Key> present;
  final List<Key> absent;
  final Matcher asOfText;
}

class _A315Case {
  const _A315Case({
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
  final ListResult<AdviceItem> advices = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  );
  final AdviceItem ad0002 = advices.rows[4];
  final AdviceItem filled = advices.rows[7];
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
    FixturePaths.m6ManualFillReceipts7,
    CommandReceipt.fromJson,
  );
  final CommandReceipt rejectedPrice = singleFixture<CommandReceipt>(
    FixturePaths.m6FillRejectedPrice,
    CommandReceipt.fromJson,
  );
  final ListResult<DraftRecord> drafts = listFixture<DraftRecord>(
    FixturePaths.m6DraftRecordsX7,
    DraftRecord.fromJson,
  );

  testWidgets('A3-01 empty form with ref card and options', (
    WidgetTester tester,
  ) async {
    expect(drafts.rows[0].key.targetId, ad0002.adviceId); // pre
    expect(ad0002.prefillQuantityLabel, isNotNull); // pre
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => throw UnimplementedError(),
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    expect(adviceShownTexts(tester, find.byKey(const Key('a3-asof'))), <String>[
      spec.asOf.label,
    ]);
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a3-ref'))),
      adviceFormRefTexts(ad0002),
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-quantity')))
          .controller
          ?.text,
      '',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-price')))
          .controller
          ?.text,
      '',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-commission')))
          .controller
          ?.text,
      '',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-tax')))
          .controller
          ?.text,
      '',
    );
    expect(spec.tradeDateOptions, hasLength(6));
    for (int i = 0; i < spec.tradeDateOptions.length; i++) {
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-date-$i')))
            .selected,
        isFalse,
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('a3-date-$i')),
                matching: find.byType(Text),
              ),
            )
            .data,
        spec.tradeDateOptions[i].label,
      );
    }
    expect(find.byKey(const ValueKey<String>('a3-date-6')), findsNothing);
    expect(spec.sides, hasLength(2));
    for (int i = 0; i < spec.sides.length; i++) {
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-side-$i')))
            .selected,
        isFalse,
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('a3-side-$i')),
                matching: find.byType(Text),
              ),
            )
            .data,
        spec.sides[i].label,
      );
    }
    expect(find.byKey(const ValueKey<String>('a3-side-2')), findsNothing);
    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-symbol')))
          .value,
      isNull,
    );
    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-account')))
          .value,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('a3-submit'))).onPressed,
      isNotNull,
    );
    expect(store.loaded, <DraftKey>[drafts.rows[0].key]);
    expect(store.saved, <DraftRecord>[]);
    expect(find.byKey(const Key('a3-receipt')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A3-02 prefill quantity button fills and keeps mark on edit', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => throw UnimplementedError(),
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-prefill')));
    await tester.tap(find.byKey(const Key('a3-prefill')));
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-quantity')))
          .controller
          ?.text,
      ad0002.prefillQuantityText,
    );
    expect(
      store.saved.last.manualFill?.quantityText,
      ad0002.prefillQuantityText,
    );
    expect(store.saved.last.manualFill?.prefilledFields, <String>[
      ManualFillPrefillFields.quantity,
    ]);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-price')))
          .controller
          ?.text,
      '',
    );

    await tester.enterText(find.byKey(const Key('a3-quantity')), '9');
    expect(store.saved.last.manualFill?.quantityText, '9');
    expect(store.saved.last.manualFill?.prefilledFields, <String>[
      ManualFillPrefillFields.quantity,
    ]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_A303Case> a303Cases = <_A303Case>[
    _A303Case(name: 'open', item: ad0002, prefill: ad0002.prefillQuantityLabel),
    _A303Case(name: 'filled', item: filled, prefill: null),
  ];
  for (final _A303Case c in a303Cases) {
    testWidgets('A3-03 prefill button presence ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(filled.prefillQuantityLabel, isNull); // pre
      final RecordingDraftStore store = RecordingDraftStore();
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: (int call) => Future<AdviceItem?>.value(c.item),
        spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => throw UnimplementedError(),
        watch: (int call) => throw UnimplementedError(),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
        adviceId: c.item.adviceId,
      );

      final String? want = c.prefill;
      if (want != null) {
        expect(
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byKey(const Key('a3-prefill')),
                  matching: find.byType(Text),
                ),
              )
              .data,
          want,
        );
      } else {
        expect(find.byKey(const Key('a3-prefill')), findsNothing);
      }
      expect(find.byKey(const Key('a3-quantity')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A3-04 input and selection persist to draft and submit raw', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (int call) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    await tester.ensureVisible(find.byKey(const ValueKey<String>('a3-date-5')));
    await tester.tap(find.byKey(const ValueKey<String>('a3-date-5')));
    expect(
      store.saved.last.manualFill?.tradeDate,
      spec.tradeDateOptions[5].date,
    );

    await manualFillPick(tester, const Key('a3-symbol'), spec.symbols[1].label);
    expect(store.saved.last.manualFill?.symbol, spec.symbols[1].symbol);

    await tester.ensureVisible(find.byKey(const ValueKey<String>('a3-side-1')));
    await tester.tap(find.byKey(const ValueKey<String>('a3-side-1')));

    await tester.enterText(find.byKey(const Key('a3-quantity')), ' 8 ');
    await tester.enterText(find.byKey(const Key('a3-price')), '18900');

    await manualFillPick(
      tester,
      const Key('a3-account'),
      spec.accounts[1].label,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    final ManualFillSubmission s = cmd.recorded.single;
    expect(s.adviceId, ad0002.adviceId);
    expect(s.input.tradeDate, spec.tradeDateOptions[5].date);
    expect(s.input.symbol, spec.symbols[1].symbol);
    expect(s.input.side, spec.sides[1].side);
    expect(s.input.quantityText, ' 8 ');
    expect(s.input.priceText, '18900');
    expect(s.input.commissionText, '');
    expect(s.input.taxText, '');
    expect(s.input.accountAlias, spec.accounts[1].alias);
    expect(s.input.prefilledFields, <String>[]);
    expect(s.retryCodes, <String>[]);
    expect(store.saved.last.manualFill, s.input);
    expect(store.saved.last.lastCommandId, receipts.rows[0].commandId);
    expect(cmd.watched, <String>[receipts.rows[0].commandId]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_A305Case> a305Cases = <_A305Case>[
    _A305Case(
      name: 'requested',
      watch: receipts.rows[0],
      enabled: isNull,
      fieldEnabled: isFalse,
      retry: null,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _A305Case(
      name: 'executed',
      watch: receipts.rows[1],
      enabled: isNull,
      fieldEnabled: isFalse,
      retry: null,
      cleared: <DraftKey>[drafts.rows[0].key],
      opened: <String>[AppNavActions.back],
    ),
    _A305Case(
      name: 'rejected_dup',
      watch: receipts.rows[2],
      enabled: isNotNull,
      fieldEnabled: isTrue,
      retry: receipts.rows[2].retryLabel,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _A305Case(
      name: 'rejected_invalid',
      watch: receipts.rows[3],
      enabled: isNotNull,
      fieldEnabled: isTrue,
      retry: null,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _A305Case(
      name: 'held',
      watch: receipts.rows[4],
      enabled: isNull,
      fieldEnabled: isFalse,
      retry: null,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _A305Case(
      name: 'lease',
      watch: receipts.rows[5],
      enabled: isNull,
      fieldEnabled: isFalse,
      retry: null,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
    _A305Case(
      name: 'stale_context',
      watch: receipts.rows[6],
      enabled: isNull,
      fieldEnabled: isFalse,
      retry: null,
      cleared: <DraftKey>[],
      opened: <String>[],
    ),
  ];
  for (final _A305Case c in a305Cases) {
    testWidgets('A3-05 receipt branch ${c.name}', (WidgetTester tester) async {
      expect(receipts.rows[2].retryLabel, isNotNull); // pre
      expect(receipts.rows[3].retryLabel, isNull); // pre
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[drafts.rows[0]],
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: (int call) => Future<AdviceItem?>.value(ad0002),
        spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
        watch: (int call) => Stream<CommandReceipt>.value(c.watch),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(
          repo: repo,
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        adviceId: ad0002.adviceId,
      );

      await tester.ensureVisible(find.byKey(const Key('a3-submit')));
      await tester.tap(find.byKey(const Key('a3-submit')));
      await tester.pump();

      expect(
        tester.widget<Text>(find.byKey(const Key('a3-receipt'))).data,
        c.watch.stateLabel,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('a3-submit')))
            .onPressed,
        c.enabled,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('a3-prefill')))
            .onPressed,
        c.enabled,
      );
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey<String>('a3-date-0')))
            .onSelected,
        c.enabled,
      );
      expect(
        tester
            .widget<DropdownButton<String>>(find.byKey(const Key('a3-symbol')))
            .onChanged,
        c.enabled,
      );
      expect(
        tester.widget<TextField>(find.byKey(const Key('a3-quantity'))).enabled,
        c.fieldEnabled,
      );

      final String? wantRetry = c.retry;
      if (wantRetry != null) {
        expect(
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byKey(const Key('a3-retry')),
                  matching: find.byType(Text),
                ),
              )
              .data,
          wantRetry,
        );
      } else {
        expect(find.byKey(const Key('a3-retry')), findsNothing);
      }
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('a3-quantity')))
            .controller
            ?.text,
        drafts.rows[0].manualFill?.quantityText,
      );
      expect(store.cleared, c.cleared);
      expect(opener.opened, c.opened);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A3-06 retry code accumulation on resubmit', (
    WidgetTester tester,
  ) async {
    expect(rejectedPrice.retryCode, isNotNull); // pre
    expect(receipts.rows[2].retryCode, isNotNull); // pre
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[drafts.rows[0]],
    );
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final List<CommandReceipt> sequence = <CommandReceipt>[
      rejectedPrice,
      receipts.rows[2],
      receipts.rows[0],
    ];
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Future<CommandReceipt>.value(sequence[call]),
      watch: (int call) => Stream<CommandReceipt>.value(sequence[call]),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('a3-retry')),
              matching: find.byType(Text),
            ),
          )
          .data,
      rejectedPrice.retryLabel,
    );

    await tester.tap(find.byKey(const Key('a3-retry')));
    await tester.pump();

    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('a3-retry')),
              matching: find.byType(Text),
            ),
          )
          .data,
      receipts.rows[2].retryLabel,
    );

    await tester.tap(find.byKey(const Key('a3-retry')));
    await tester.pump();

    expect(
      <List<String>>[
        for (final ManualFillSubmission s in cmd.recorded) s.retryCodes,
      ],
      <List<String>>[
        <String>[],
        <String>[rejectedPrice.retryCode!],
        <String>[rejectedPrice.retryCode!, receipts.rows[2].retryCode!],
      ],
    );
    expect(store.saved.last.manualFill, cmd.recorded.last.input);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A3-07 draft restored into inputs and chips', (
    WidgetTester tester,
  ) async {
    expect(drafts.rows[0].manualFill?.prefilledFields, isNotEmpty); // pre
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[drafts.rows[0]],
    );
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (int call) => Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-quantity')))
          .controller
          ?.text,
      drafts.rows[0].manualFill?.quantityText,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-price')))
          .controller
          ?.text,
      drafts.rows[0].manualFill?.priceText,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-commission')))
          .controller
          ?.text,
      drafts.rows[0].manualFill?.commissionText,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('a3-tax')))
          .controller
          ?.text,
      drafts.rows[0].manualFill?.taxText,
    );
    for (int i = 0; i < spec.tradeDateOptions.length; i++) {
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-date-$i')))
            .selected,
        spec.tradeDateOptions[i].date == drafts.rows[0].manualFill?.tradeDate,
      );
    }
    for (int i = 0; i < spec.sides.length; i++) {
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-side-$i')))
            .selected,
        spec.sides[i].side == drafts.rows[0].manualFill?.side,
      );
    }
    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-symbol')))
          .value,
      drafts.rows[0].manualFill?.symbol,
    );
    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-account')))
          .value,
      drafts.rows[0].manualFill?.accountAlias,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    expect(cmd.recorded.single.input, drafts.rows[0].manualFill);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_A308Case> a308Cases = <_A308Case>[
    _A308Case(
      name: 'restored_requested',
      watch: receipts.rows[0],
      receipt: receipts.rows[0].stateLabel,
      enabled: isNull,
      quantity: drafts.rows[0].manualFill?.quantityText ?? '',
      cleared: <DraftKey>[],
    ),
    _A308Case(
      name: 'restored_executed',
      watch: receipts.rows[1],
      receipt: null,
      enabled: isNotNull,
      quantity: '',
      cleared: <DraftKey>[drafts.rows[0].key],
    ),
  ];
  for (final _A308Case c in a308Cases) {
    testWidgets('A3-08 restored command id ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(drafts.rows[0].lastCommandId, isNull); // pre
      final DraftRecord seed = manualFillSeedWithCommand(
        drafts.rows[0],
        receipts.rows[0].commandId,
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[seed],
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: (int call) => Future<AdviceItem?>.value(ad0002),
        spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => throw UnimplementedError(),
        watch: (int call) => Stream<CommandReceipt>.value(c.watch),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(
          repo: repo,
          cmd: cmd,
          store: store,
          opener: opener,
        ),
        adviceId: ad0002.adviceId,
      );

      expect(cmd.watched, <String>[receipts.rows[0].commandId]);
      final String? wantReceipt = c.receipt;
      if (wantReceipt != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a3-receipt'))).data,
          wantReceipt,
        );
      } else {
        expect(find.byKey(const Key('a3-receipt')), findsNothing);
      }
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('a3-submit')))
            .onPressed,
        c.enabled,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('a3-quantity')))
            .controller
            ?.text,
        c.quantity,
      );
      expect(store.cleared, c.cleared);
      expect(opener.opened, <String>[]);
      expect(cmd.recorded, <ManualFillSubmission>[]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  final List<_A309Case> a309Cases = <_A309Case>[
    _A309Case(
      name: 'blocked',
      spec: blockedSpec,
      blocked: blockedSpec.blockedText,
      banner: blockedSpec.bannerText,
      submit: findsNothing,
    ),
    _A309Case(
      name: 'normal',
      spec: spec,
      blocked: null,
      banner: null,
      submit: findsOneWidget,
    ),
  ];
  for (final _A309Case c in a309Cases) {
    testWidgets('A3-09 blocked text and form banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(blockedSpec.blockedText, isNotNull); // pre
      expect(blockedSpec.bannerText, isNotNull); // pre
      final RecordingDraftStore store = RecordingDraftStore();
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: (int call) => Future<AdviceItem?>.value(ad0002),
        spec: (int call) => Stream<ManualFillFormSpec>.value(c.spec),
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => throw UnimplementedError(),
        watch: (int call) => throw UnimplementedError(),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
        adviceId: ad0002.adviceId,
      );

      final String? wantBlocked = c.blocked;
      if (wantBlocked != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a3-blocked'))).data,
          wantBlocked,
        );
      } else {
        expect(find.byKey(const Key('a3-blocked')), findsNothing);
      }

      final String? wantBanner = c.banner;
      if (wantBanner != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a3-banner'))).data,
          wantBanner,
        );
      } else {
        expect(find.byKey(const Key('a3-banner')), findsNothing);
      }

      expect(find.byKey(const Key('a3-submit')), c.submit);
      expect(find.byKey(const Key('a3-quantity')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A3-10 stale spec does not open form', (
    WidgetTester tester,
  ) async {
    expect(staleSpec.asOf.staleLabel, isNotNull); // pre
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(staleSpec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => throw UnimplementedError(),
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    expect(adviceShownTexts(tester, find.byKey(const Key('a3-asof'))), <String>[
      staleSpec.asOf.label,
    ]);
    expect(find.text(staleSpec.asOf.staleLabel!), findsOneWidget);
    expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    expect(find.byKey(const Key('a3-ref')), findsNothing);
    expect(find.byKey(const Key('a3-quantity')), findsNothing);
    expect(find.byKey(const Key('a3-submit')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A3-11 submit future error shows one not accepted line', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Future<CommandReceipt>.error(StateError('fail')),
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    expect(
      tester.widget<Text>(find.byKey(const Key('a3-submit-not-accepted'))).data,
      JournalLabels.submitNotAccepted,
    );
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('a3-submit'))).onPressed,
      isNotNull,
    );
    expect(cmd.watched, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
    expect(tester.takeException(), isNotNull);
  });

  testWidgets('A3-12 resubscribe after a stream error', (
    WidgetTester tester,
  ) async {
    final DraftRecord seed = manualFillSeedWithCommand(
      drafts.rows[0],
      receipts.rows[0].commandId,
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[seed],
    );
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => throw UnimplementedError(),
      watch: (int call) => call == 0
          ? Stream<CommandReceipt>.error(StateError('fail'))
          : Stream<CommandReceipt>.value(receipts.rows[0]),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    expect(find.byKey(const Key('a3-resubscribe')), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('a3-submit'))).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('a3-resubscribe')));
    await tester.pump();

    expect(
      tester.widget<Text>(find.byKey(const Key('a3-receipt'))).data,
      receipts.rows[0].stateLabel,
    );
    expect(cmd.watched, <String>[
      receipts.rows[0].commandId,
      receipts.rows[0].commandId,
    ]);
    expect(tester.takeException(), isNotNull);
  });

  final List<_A313Case> a313Cases = <_A313Case>[
    _A313Case(
      name: 'draft_pending',
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      store: _NeverDraftStore(),
      present: <Key>[const Key('a3-loading')],
      absent: <Key>[const Key('a3-asof'), const Key('a3-quantity')],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'item_loading',
      item: (int call) => Completer<AdviceItem?>().future,
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-loading')],
      absent: <Key>[const Key('a3-asof')],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'item_fail',
      item: (int call) => Future<AdviceItem?>.error(StateError('fail')),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-fail')],
      absent: <Key>[const Key('a3-loading'), const Key('a3-asof')],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'item_null',
      item: (int call) => Future<AdviceItem?>.value(null),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-absent')],
      absent: <Key>[
        const Key('a3-asof'),
        const Key('a3-quantity'),
        const Key('a3-submit'),
      ],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'spec_loading',
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.fromFuture(
        Completer<ManualFillFormSpec>().future,
      ),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-loading')],
      absent: <Key>[const Key('a3-asof')],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'spec_fail',
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.error(StateError('fail')),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-fail')],
      absent: <Key>[const Key('a3-loading'), const Key('a3-asof')],
      asOfText: findsNothing,
    ),
    _A313Case(
      name: 'spec_value_then_fail',
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => adviceValueThenFail(spec),
      store: RecordingDraftStore(),
      present: <Key>[const Key('a3-fail')],
      absent: <Key>[const Key('a3-asof'), const Key('a3-quantity')],
      asOfText: findsOneWidget,
    ),
  ];
  for (final _A313Case c in a313Cases) {
    testWidgets('A3-13 state branches ${c.name}', (WidgetTester tester) async {
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: c.item,
        spec: c.spec,
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => throw UnimplementedError(),
        watch: (int call) => throw UnimplementedError(),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(repo: repo, cmd: cmd, store: c.store),
        adviceId: ad0002.adviceId,
      );

      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(spec.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      tester.takeException();
    });
  }

  final List<_A315Case> a315Cases = <_A315Case>[
    _A315Case(
      name: 'item',
      item: (int call) => call == 0
          ? Future<AdviceItem?>.error(StateError('fail'))
          : Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
      findArgs: <String>[ad0002.adviceId, ad0002.adviceId],
      specCalls: 1,
    ),
    _A315Case(
      name: 'spec',
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => call == 0
          ? Stream<ManualFillFormSpec>.error(StateError('fail'))
          : Stream<ManualFillFormSpec>.value(spec),
      findArgs: <String>[ad0002.adviceId],
      specCalls: 2,
    ),
  ];
  for (final _A315Case c in a315Cases) {
    testWidgets('A3-15 retry invalidates providers ${c.name}', (
      WidgetTester tester,
    ) async {
      final RecordingDraftStore store = RecordingDraftStore();
      final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
        item: c.item,
        spec: c.spec,
      );
      final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
        record: (int call) => throw UnimplementedError(),
        watch: (int call) => throw UnimplementedError(),
      );
      await pumpManualFill(
        tester,
        overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
        adviceId: ad0002.adviceId,
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('a3-fail')),
          matching: find.text(JournalLabels.retry),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('a3-asof')), findsOneWidget);
      expect(repo.findArgs, c.findArgs);
      expect(repo.specCalls, c.specCalls);
      expect(find.text(JournalLabels.retry), findsNothing);
      tester.takeException();
    });
  }

  testWidgets('A3-16 restored executed resets choices and prefilled mark', (
    WidgetTester tester,
  ) async {
    expect(drafts.rows[0].manualFill?.prefilledFields, isNotEmpty); // pre
    final DraftRecord seed = manualFillSeedWithCommand(
      drafts.rows[0],
      receipts.rows[0].commandId,
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[seed],
    );
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
      watch: (int call) => Stream<CommandReceipt>.value(
        call == 0 ? receipts.rows[1] : receipts.rows[0],
      ),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-symbol')))
          .value,
      isNull,
    );
    expect(
      tester
          .widget<DropdownButton<String>>(find.byKey(const Key('a3-account')))
          .value,
      isNull,
    );
    expect(
      <bool>[
        for (int i = 0; i < spec.tradeDateOptions.length; i++)
          tester
              .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-date-$i')))
              .selected,
      ],
      <bool>[for (int i = 0; i < spec.tradeDateOptions.length; i++) false],
    );
    expect(
      <bool>[
        for (int i = 0; i < spec.sides.length; i++)
          tester
              .widget<ChoiceChip>(find.byKey(ValueKey<String>('a3-side-$i')))
              .selected,
      ],
      <bool>[for (int i = 0; i < spec.sides.length; i++) false],
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    expect(cmd.recorded.single.input.prefilledFields, <String>[]);
    expect(cmd.recorded.single.retryCodes, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A3-17 submit in flight disables submit button', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => Completer<CommandReceipt>().future,
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    await tester.ensureVisible(find.byKey(const Key('a3-submit')));
    await tester.tap(find.byKey(const Key('a3-submit')));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('a3-submit'))).onPressed,
      isNull,
    );
    expect(cmd.watched, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A3-14 every Text is allowed and large font has no overflow', (
    WidgetTester tester,
  ) async {
    final RecordingDraftStore store = RecordingDraftStore();
    final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
      item: (int call) => Future<AdviceItem?>.value(ad0002),
      spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
    );
    final FakeManualFillCommandApi cmd = FakeManualFillCommandApi(
      record: (int call) => throw UnimplementedError(),
      watch: (int call) => throw UnimplementedError(),
    );
    await pumpManualFill(
      tester,
      overrides: manualFillOverrides(repo: repo, cmd: cmd, store: store),
      adviceId: ad0002.adviceId,
    );

    final Set<String> allowed = manualFillAllowed(spec, ad0002);
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
