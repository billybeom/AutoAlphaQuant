// test/ledger_repairs_test.dart — L-2 LedgerRepairs widget tests (L2-01 ~ L2-09).
//
// Rules: extends-only fakes, fixture-sourced expected strings, ASCII test names,
// no Korean literals, no collection-if, no name/which comparison.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'ledger_fakes.dart';

// ── L2-03 cases ───────────────────────────────────────────────────────────────

class _L203Case {
  const _L203Case({
    required this.name,
    required this.rowIndex,
    required this.want,
    required this.steps,
    required this.opened,
  });
  final String name;
  final int rowIndex;
  final String? want;
  final Future<void> Function(WidgetTester) steps;
  final List<String> opened;
}

// ── L2-05 cases ───────────────────────────────────────────────────────────────

class _L205Case {
  const _L205Case({
    required this.name,
    required this.input,
    required this.wantEmpty,
    required this.firstRow,
  });
  final String name;
  final ListResult<LedgerRepairRow> Function() input;
  final String? Function() wantEmpty;
  final Matcher firstRow;
}

// ── L2-06 cases ───────────────────────────────────────────────────────────────

class _L206Case {
  const _L206Case({
    required this.name,
    required this.repairs,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
  });
  final String name;
  final Stream<ListResult<LedgerRepairRow>> Function(int) repairs;
  final Clock? clock;
  final List<Key> present;
  final List<Key> absent;
  final Matcher stale;
  final Matcher asOfText;
}

double _dx(WidgetTester tester, int i) => tester
    .getTopLeft(
      find.descendant(
        of: find.byKey(ValueKey<String>('l2-row-$i')),
        matching: find.byType(Text),
      ).first,
    )
    .dx;

void main() {
  final ListResult<LedgerRepairRow> four = listFixture(
    FixturePaths.m6LedgerRepairs4,
    LedgerRepairRow.fromJson,
  );
  final ListResult<LedgerRepairRow> empty = listFixture(
    FixturePaths.m6LedgerRepairsEmpty,
    LedgerRepairRow.fromJson,
  );

  // ── L2-03 case definitions (uses four) ───────────────────────────────────────

  List<_L203Case> l203cases() => <_L203Case>[
    _L203Case(
      name: 'with_link',
      rowIndex: 1,
      want: four.rows[1].decisionLink!.label,
      steps: (WidgetTester t) async {
        await t.tap(
          find.descendant(
            of: find.byKey(const ValueKey<String>('l2-row-1')),
            matching: find.byType(TextButton),
          ),
        );
        await t.pump();
      },
      opened: <String>[four.rows[1].decisionLink!.deepLink],
    ),
    _L203Case(
      name: 'no_link',
      rowIndex: 0,
      want: null,
      steps: (WidgetTester t) async {},
      opened: <String>[],
    ),
  ];

  // ── L2-05 case definitions (uses four + empty) ────────────────────────────────

  List<_L205Case> l205cases() => <_L205Case>[
    _L205Case(
      name: 'empty_fixture',
      input: () => empty,
      wantEmpty: () => empty.emptyLabel,
      firstRow: findsNothing,
    ),
    _L205Case(
      name: 'four',
      input: () => four,
      wantEmpty: () => null,
      firstRow: findsOneWidget,
    ),
    _L205Case(
      name: 'slice_empty',
      input: () => ledgerRepairSlice(four, <int>[]),
      wantEmpty: () => null,
      firstRow: findsNothing,
    ),
  ];

  // ── L2-06 case definitions ────────────────────────────────────────────────────

  List<_L206Case> l206cases() => <_L206Case>[
    _L206Case(
      name: 'loading',
      repairs: (int call) => Stream<ListResult<LedgerRepairRow>>.fromFuture(
        Completer<ListResult<LedgerRepairRow>>().future,
      ),
      clock: null,
      present: <Key>[const Key('l2-loading')],
      absent: <Key>[const Key('l2-asof'), const Key('l2-fail')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _L206Case(
      name: 'fail',
      repairs: (int call) =>
          Stream<ListResult<LedgerRepairRow>>.error(StateError('fail')),
      clock: null,
      present: <Key>[const Key('l2-fail')],
      absent: <Key>[const Key('l2-loading'), const Key('l2-asof')],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _L206Case(
      name: 'value_then_fail',
      repairs: (int call) => ledgerValueThenFail(four),
      clock: null,
      present: <Key>[const Key('l2-fail')],
      absent: <Key>[
        const Key('l2-asof'),
        const ValueKey<String>('l2-row-0'),
      ],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _L206Case(
      name: 'stale',
      repairs: (int call) =>
          Stream<ListResult<LedgerRepairRow>>.value(four),
      clock: ledgerStaleClock(),
      present: <Key>[
        const Key('l2-asof'),
        const ValueKey<String>('l2-row-0'),
      ],
      absent: <Key>[const Key('l2-loading'), const Key('l2-fail')],
      stale: findsOneWidget,
      asOfText: findsOneWidget,
    ),
  ];

  // L2-01 full list, received order, indentation, no-args
  testWidgets('L2-01 full list received order indentation', (
    WidgetTester tester,
  ) async {
    expect(four.rows[0].supersedes, isNull); // pre
    expect(four.rows[2].supersedes, isNotNull); // pre
    final FakeLedgerRepairsRepository repo = FakeLedgerRepairsRepository(
      repairs: (int call) =>
          Stream<ListResult<LedgerRepairRow>>.value(four),
    );
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(repo: repo),
    );
    expect(four.rows, hasLength(4));
    for (final (int i, LedgerRepairRow r) in four.rows.indexed) {
      expect(
        ledgerShownTexts(tester, find.byKey(ValueKey<String>('l2-row-$i'))),
        ledgerRepairTexts(r),
      );
    }
    expect(find.byKey(const ValueKey<String>('l2-row-4')), findsNothing);
    final double dyAsOf =
        tester.getTopLeft(find.byKey(const Key('l2-asof'))).dy;
    final double dyRow0 =
        tester.getTopLeft(find.byKey(const ValueKey<String>('l2-row-0'))).dy;
    final double dyRow1 =
        tester.getTopLeft(find.byKey(const ValueKey<String>('l2-row-1'))).dy;
    final double dyRow2 =
        tester.getTopLeft(find.byKey(const ValueKey<String>('l2-row-2'))).dy;
    final double dyRow3 =
        tester.getTopLeft(find.byKey(const ValueKey<String>('l2-row-3'))).dy;
    expect(dyAsOf, lessThan(dyRow0));
    expect(dyRow0, lessThan(dyRow1));
    expect(dyRow1, lessThan(dyRow2));
    expect(dyRow2, lessThan(dyRow3));
    for (final (int i, LedgerRepairRow r) in four.rows.indexed) {
      expect(
        _dx(tester, i),
        r.supersedes == null ? _dx(tester, 0) : greaterThan(_dx(tester, 0)),
      );
    }
    expect(repo.limits, <int>[50]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L2-02 direction badge color = shared tone
  testWidgets('L2-02 direction badge color shared tone', (
    WidgetTester tester,
  ) async {
    expect(
      <ChipTone>{for (final LedgerRepairRow r in four.rows) r.directionTone},
      <ChipTone>{ChipTone.neutral, ChipTone.caution},
    ); // pre
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerRepairsRepository(
          repairs: (int call) =>
              Stream<ListResult<LedgerRepairRow>>.value(four),
        ),
      ),
    );
    for (final (int i, LedgerRepairRow r) in four.rows.indexed) {
      final Finder rowFinder = find.byKey(ValueKey<String>('l2-row-$i'));
      expect(
        find.descendant(of: rowFinder, matching: find.byType(Chip)),
        findsOneWidget,
      );
      expect(
        tester.widget<Chip>(
          find.descendant(of: rowFinder, matching: find.byType(Chip)),
        ).backgroundColor,
        journalToneColor(
          tester.element(find.byType(LedgerRepairs)),
          r.directionTone,
        ),
      );
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L2-03 decision link present/absent — per case
  for (final _L203Case c in l203cases()) {
    testWidgets('L2-03 decision link ${c.name}', (WidgetTester tester) async {
      expect(four.rows[1].decisionLink, isNotNull); // pre
      expect(four.rows[0].decisionLink, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpLedgerRepairs(
        tester,
        overrides: ledgerOverrides(
          repo: FakeLedgerRepairsRepository(
            repairs: (int call) =>
                Stream<ListResult<LedgerRepairRow>>.value(four),
          ),
          opener: opener,
        ),
      );
      final String? want = c.want;
      final Finder rowFinder =
          find.byKey(ValueKey<String>('l2-row-${c.rowIndex}'));
      if (want != null) {
        expect(
          ledgerShownTexts(
            tester,
            find.descendant(of: rowFinder, matching: find.byType(TextButton)),
          ),
          <String?>[want],
        );
      } else {
        expect(
          find.descendant(of: rowFinder, matching: find.byType(TextButton)),
          findsNothing,
        );
      }
      await c.steps(tester);
      expect(opener.opened, c.opened);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // L2-04 chain stamp copy
  testWidgets('L2-04 chain stamp copy', (WidgetTester tester) async {
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerRepairsRepository(
          repairs: (int call) =>
              Stream<ListResult<LedgerRepairRow>>.value(four),
        ),
        opener: opener,
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('l2-row-1')),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pump();
    expect(
      calls
          .where((MethodCall c) => c.method == 'Clipboard.setData')
          .map(
            (MethodCall c) =>
                (c.arguments as Map<Object?, Object?>)['text'],
          )
          .toList(),
      <Object?>[four.rows[1].chainStampText],
    );
    for (final (int i, LedgerRepairRow r) in four.rows.indexed) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('l2-row-$i')),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
    }
    expect(opener.opened, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L2-05 empty label — per case
  for (final _L205Case c in l205cases()) {
    testWidgets('L2-05 empty label ${c.name}', (WidgetTester tester) async {
      expect(empty.rows, isEmpty); // pre
      expect(empty.emptyLabel, isNotNull); // pre
      expect(four.emptyLabel, isNull); // pre
      await pumpLedgerRepairs(
        tester,
        overrides: ledgerOverrides(
          repo: FakeLedgerRepairsRepository(
            repairs: (int call) =>
                Stream<ListResult<LedgerRepairRow>>.value(c.input()),
          ),
        ),
      );
      final String? wantEmpty = c.wantEmpty();
      if (wantEmpty != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('l2-empty'))).data,
          wantEmpty,
        );
      } else {
        expect(find.byKey(const Key('l2-empty')), findsNothing);
      }
      expect(
        find.byKey(const ValueKey<String>('l2-row-0')),
        c.firstRow,
      );
      expect(find.byKey(const Key('l2-asof')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // L2-06 state x branches — per case
  for (final _L206Case c in l206cases()) {
    testWidgets('L2-06 state branches ${c.name}', (WidgetTester tester) async {
      await pumpLedgerRepairs(
        tester,
        overrides: ledgerOverrides(
          repo: FakeLedgerRepairsRepository(repairs: c.repairs),
          clock: c.clock,
        ),
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(four.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // L2-07 retry
  testWidgets('L2-07 retry invalidates and reloads', (
    WidgetTester tester,
  ) async {
    final FakeLedgerRepairsRepository repo = FakeLedgerRepairsRepository(
      repairs: (int call) =>
          call == 0
              ? Stream<ListResult<LedgerRepairRow>>.error(StateError('fail'))
              : Stream<ListResult<LedgerRepairRow>>.value(four),
    );
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(repo: repo),
    );
    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('l2-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('l2-row-0')), findsOneWidget);
    expect(repo.limits, <int>[50, 50]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L2-08 safety banner = shared component
  testWidgets('L2-08 safety banner shared component', (
    WidgetTester tester,
  ) async {
    final SafetyState safety3 = safetyFixtureRow(3);
    expect(safety3.activeFlags, isNotEmpty); // pre
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerRepairsRepository(
          repairs: (int call) =>
              Stream<ListResult<LedgerRepairRow>>.value(four),
        ),
        safety: safety3,
      ),
    );
    final String firstFlagLabel = safety3.activeFlags.first.label;
    expect(find.text(firstFlagLabel), findsOneWidget);
    final double dyBanner =
        tester.getTopLeft(find.text(firstFlagLabel)).dy;
    final double dyAsOf =
        tester.getTopLeft(find.byKey(const Key('l2-asof'))).dy;
    final double dyRow0 =
        tester.getTopLeft(find.byKey(const ValueKey<String>('l2-row-0'))).dy;
    expect(dyBanner, greaterThan(dyAsOf));
    expect(dyBanner, lessThan(dyRow0));
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L2-09 all screen texts large font
  testWidgets('L2-09 all screen texts large font scale', (
    WidgetTester tester,
  ) async {
    final Set<String> allowed = ledgerRepairsAllowed(four);
    await pumpLedgerRepairs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerRepairsRepository(
          repairs: (int call) =>
              Stream<ListResult<LedgerRepairRow>>.value(four),
        ),
      ),
    );
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
